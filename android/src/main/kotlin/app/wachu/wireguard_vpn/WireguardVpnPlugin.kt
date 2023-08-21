package app.wachu.wireguard_vpn

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import android.app.Application
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.content.Context
import android.util.Log
import com.beust.klaxon.Klaxon
import com.wireguard.android.backend.*
//import com.wireguard.android.util.ModuleLoader
import com.wireguard.android.util.RootShell
import com.wireguard.android.util.ToolsInstaller
import com.wireguard.config.Config
import com.wireguard.config.Interface
import com.wireguard.config.Peer
import kotlinx.coroutines.*
import java.util.*


import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

/** WireguardVpnPlugin */
class WireguardVpnPlugin: FlutterPlugin, MethodCallHandler ,ActivityAware,PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private val permissionRequestCode = 10014
    private val channelName = "wachu985/wireguard-flutter"
    private val futureBackend = CompletableDeferred<Backend>()
    private val scope = CoroutineScope(Job() + Dispatchers.Main.immediate)
    private var backend: Backend? = null
    private lateinit var rootShell: RootShell
    private lateinit var toolsInstaller: ToolsInstaller
    private var havePermission = false
    private lateinit var context:Context 
    private var activity:Activity? = null

    // Have to keep tunnels, because WireGuard requires to use the _same_
    // instance of a tunnel every time you change the state.
    private var tunnels = HashMap<String, Tunnel>()

    companion object {
    const val TAG = "MainActivity"
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean{
        //super.onActivityResult(requestCode, resultCode, data)
       havePermission = (requestCode == permissionRequestCode) && (resultCode == Activity.RESULT_OK)
       return havePermission

    }

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        Log.d(TAG, "Entre 1")
        this.activity = activityPluginBinding.activity as FlutterActivity
    // TODO: your plugin is now attached to an Activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    // TODO: the Activity your plugin was attached to was
    // destroyed to change configuration.
    // This call will be followed by onReattachedToActivityForConfigChanges().
        this.activity = null;
    }

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
    // TODO: your plugin is now attached to a new Activity
    // after a configuration change.
        this.activity = activityPluginBinding.activity as FlutterActivity
    }

    override fun onDetachedFromActivity() {
    // TODO: your plugin is no longer associated with an Activity.
    // Clean up references.
        this.activity = null;
    }
  
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        context = flutterPluginBinding.applicationContext
        rootShell = RootShell(context)
        toolsInstaller = ToolsInstaller(context, rootShell)
    
        scope.launch(Dispatchers.IO) {
            try {
                backend = createBackend()
                Log.e(TAG, "Entre 1")
                futureBackend.complete(backend!!)
                checkPermission()
            } catch (e: Throwable) {
                Log.e(TAG, Log.getStackTraceString(e))
            }
        }
        channel.setMethodCallHandler(this)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when (call.method) {
            "getTunnelNames" -> handleGetNames(result)
            "setState" -> handleSetState(call.arguments, result)
            "getStats" -> handleGetStats(call.arguments, result)
            else -> flutterNotImplemented(result)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun checkPermission() {
            val intent = GoBackend.VpnService.prepare(this.activity)
            if (intent != null) {
                havePermission = false
                this.activity?.startActivityForResult(intent, permissionRequestCode)
            } else {
                havePermission = true
            }
    }

    private fun createBackend(): Backend {
            var backend: Backend? = null
            var didStartRootShell = false
            try {
                if (!didStartRootShell) {
                    rootShell.start()
                }
                val wgQuickBackend = WgQuickBackend(context, rootShell, toolsInstaller)
                //wgQuickBackend.setMultipleTunnels(UserKnobs.multipleTunnels.first())
                backend = wgQuickBackend
                // what is that? I totally did not understand
                /*UserKnobs.multipleTunnels.onEach {
                wgQuickBackend.setMultipleTunnels(it)
                }.launchIn(coroutineScope)*/
            } catch (ignored: Exception) {
                Log.e(TAG, Log.getStackTraceString(ignored))
            }
            if (backend == null) {
                backend = GoBackend(context)
            }
            return backend
    }

    private fun flutterSuccess(result: MethodChannel.Result, o: Any) {
        scope.launch(Dispatchers.Main) {
            result.success(o)
        }
    }

    private fun flutterError(result: MethodChannel.Result, error: String) {
        scope.launch(Dispatchers.Main) {
            result.error(error, null, null)
        }
    }

    private fun flutterNotImplemented(result: MethodChannel.Result) {
        scope.launch(Dispatchers.Main) {
            result.notImplemented()
        }
    }

    private fun handleSetState(arguments: Any, result: MethodChannel.Result) {

        scope.launch(Dispatchers.IO) {
            try {
                val params = Klaxon().parse<SetStateParams>(arguments.toString())
                if (params == null) {
                    flutterError(result, "Set state params is missing")
                    return@launch
                }

                val config = Config.Builder()
                    .setInterface(
                        Interface.Builder()
                            .parseAddresses(params.tunnel.address)
                            .parseListenPort(params.tunnel.listenPort)
                            .parseDnsServers(params.tunnel.dnsServer)
                            .parsePrivateKey(params.tunnel.privateKey)
                            .build(),
                    )
                    .addPeer(
                        Peer.Builder()
                            .parseAllowedIPs(params.tunnel.peerAllowedIp)
                            .parsePublicKey(params.tunnel.peerPublicKey)
                            .parseEndpoint(params.tunnel.peerEndpoint)
                            .parsePreSharedKey(params.tunnel.peerPresharedKey)
                            .parsePersistentKeepalive("25")
                            .build()
                    )
                    .build()
                //futureBackend.await().setState(MyTunnel(params.tunnel.name), params.tuTunnel.State.UP, config)
                futureBackend.await().setState(
                    tunnel(params.tunnel.name) { state ->
                        scope.launch(Dispatchers.Main) {
                            Log.i(TAG, "onStateChange - $state")
                            channel?.invokeMethod(
                                "onStateChange",
                                Klaxon().toJsonString(
                                    StateChangeData(params.tunnel.name, state == Tunnel.State.UP)
                                )
                            )
                        }
                    },
                    if (params.state) Tunnel.State.UP else Tunnel.State.DOWN,
                    config
                )
                Log.i(TAG, "handleSetState - success!")
                flutterSuccess(result, params.state)
            } catch (e: BackendException) {
                Log.e(TAG, "handleSetState - BackendException - ERROR - ${e.reason}")
                flutterError(result, e.reason.toString())
            } catch (e: Throwable) {
                Log.e(TAG, "handleSetState - Can't set tunnel state: $e, ${Log.getStackTraceString(e)}")
                flutterError(result, e.message.toString())
            }
        }
    }

    private fun handleGetNames(result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                val names = futureBackend.await().runningTunnelNames
                Log.i(TAG, "Success $names")
                flutterSuccess(result, names.toString())
            } catch (e: Throwable) {
                Log.e(TAG, "Can't get tunnel names: " + e.message + " " + e.stackTrace)
                flutterError(result, "Can't get tunnel names")
            }
        }
    }

    private fun handleGetStats(arguments: Any?, result: MethodChannel.Result) {
        val tunnelName = arguments?.toString()
        if (tunnelName == null || tunnelName.isEmpty()) {
            flutterError(result, "Provide tunnel name to get statistics")
            return
        }

        scope.launch(Dispatchers.IO) {

            try {
                val stats = futureBackend.await().getStatistics(tunnel(tunnelName))

                flutterSuccess(result, Klaxon().toJsonString(
                    Stats(stats.totalRx(), stats.totalTx())
                ))

            } catch (e: BackendException) {
                Log.e(TAG, "handleGetStats - BackendException - ERROR - ${e.reason}")
                flutterError(result, e.reason.toString())
            } catch (e: Throwable) {
                Log.e(TAG, "handleGetStats - Can't get stats: $e")
                flutterError(result, e.message.toString())
            }
        }
    }

    /**
     * Return existing [MyTunnel] from the [tunnels], or create new, add to the list and return it
     */
    private fun tunnel(name: String, callback: StateChangeCallback? = null): Tunnel {
        return tunnels.getOrPut(name, { MyTunnel(name, callback) })
    }
}


typealias StateChangeCallback = (Tunnel.State) -> Unit

class MyTunnel(private val name: String,
               private val onStateChanged: StateChangeCallback? = null) : Tunnel {

    override fun getName() = name

    override fun onStateChange(newState: Tunnel.State) {
        onStateChanged?.invoke(newState)
    }

}

class SetStateParams(
    val state: Boolean,
    val tunnel: TunnelData
)

class TunnelData(
    val name: String,
    val address: String,
    val listenPort: String,
    val dnsServer: String,
    val privateKey: String,
    val peerAllowedIp: String,
    val peerPublicKey: String,
    val peerEndpoint: String,
    val peerPresharedKey:String
)

class StateChangeData(
    val tunnelName: String,
    val tunnelState: Boolean,
)

class Stats(
    val totalDownload: Long,
    val totalUpload: Long,
)
