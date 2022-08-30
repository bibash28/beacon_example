package com.bibash.beacon.beacon_example

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateAccount
import it.airgap.beaconsdk.blockchain.substrate.data.SubstrateNetwork
import it.airgap.beaconsdk.blockchain.substrate.message.request.PermissionSubstrateRequest
import it.airgap.beaconsdk.blockchain.substrate.message.response.PermissionSubstrateResponse
import it.airgap.beaconsdk.blockchain.substrate.substrate
import it.airgap.beaconsdk.blockchain.tezos.data.TezosAccount
import it.airgap.beaconsdk.blockchain.tezos.data.TezosError
import it.airgap.beaconsdk.blockchain.tezos.data.TezosNetwork
import it.airgap.beaconsdk.blockchain.tezos.extension.from
import it.airgap.beaconsdk.blockchain.tezos.message.request.BroadcastTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.OperationTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.PermissionTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.request.SignPayloadTezosRequest
import it.airgap.beaconsdk.blockchain.tezos.message.response.PermissionTezosResponse
import it.airgap.beaconsdk.blockchain.tezos.tezos
import it.airgap.beaconsdk.client.wallet.BeaconWalletClient
import it.airgap.beaconsdk.client.wallet.compat.stop
import it.airgap.beaconsdk.core.client.BeaconClient
import it.airgap.beaconsdk.core.data.BeaconError
import it.airgap.beaconsdk.core.message.BeaconMessage
import it.airgap.beaconsdk.core.message.BeaconRequest
import it.airgap.beaconsdk.core.message.ErrorBeaconResponse
import it.airgap.beaconsdk.core.message.PermissionBeaconRequest
import it.airgap.beaconsdk.transport.p2p.matrix.p2pMatrix
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

class BeaconPlugin : MethodChannel.MethodCallHandler {
    val tag = "BeaconPlugin"

    private lateinit var methodChannel: MethodChannel

    fun createChannels(@NonNull flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "beaconMethod")
        methodChannel.setMethodCallHandler(this)

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startBeacon" -> {
                startBeacon()
            }
            "respondExample" ->
                respondExample(call, result)
            "pair" -> {
                val pairingRequest: String = call.argument("pairingRequest") ?: ""
                pair(pairingRequest, result)
            }
            "removePeers" -> {
                removePeers(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }


    private var beaconClient: BeaconWalletClient? = null
    private var awaitingRequest: BeaconRequest? = null


    private fun startBeacon() {
        CoroutineScope(Dispatchers.IO).launch {
            beaconClient?.stop()
            beaconClient = BeaconWalletClient("Altme") {
                support(tezos(), substrate())
                use(p2pMatrix())

                ignoreUnsupportedBlockchains = true
            }

            launch {
                beaconClient?.connect()
                    ?.onEach { result -> result.getOrNull()?.let { saveAwaitingRequest(it) } }
                    ?.collect { result ->
                        result.getOrNull()?.let {
                            when (it) {
                                is PermissionBeaconRequest -> {


                                }
                                else -> {

                                }
                            }
                        }
                    }
            }
        }
    }

    private fun respondExample(call: MethodCall, result: Result) {
        val request = awaitingRequest ?: return
        val beaconClient = beaconClient ?: return

        Log.i(tag, request.toString())

        CoroutineScope(Dispatchers.IO).launch {

            val peers = beaconClient.getPeers()
            if (peers.isEmpty()) return@launch

            val response = when (request) {
                /* Tezos */

                is PermissionTezosRequest -> PermissionTezosResponse.from(
                    request,
                    exampleTezosAccount(request.network, beaconClient)
                )
                is OperationTezosRequest -> ErrorBeaconResponse.from(request, BeaconError.Aborted)
                is SignPayloadTezosRequest -> ErrorBeaconResponse.from(
                    request,
                    TezosError.SignatureTypeNotSupported
                )
                is BroadcastTezosRequest -> ErrorBeaconResponse.from(
                    request,
                    TezosError.BroadcastError
                )

                /* Substrate*/

                is PermissionSubstrateRequest -> PermissionSubstrateResponse.from(
                    request,
                    listOf(exampleSubstrateAccount(request.networks.first(), beaconClient))
                )

                /* Others */
                else -> ErrorBeaconResponse.from(request, BeaconError.Unknown)
            }
            beaconClient.respond(response)
            removeAwaitingRequest()
            result.success(mapOf("error" to 0))
        }
    }

    private fun pair(pairingRequest: String, result: Result) {
        CoroutineScope(Dispatchers.IO).launch {
            beaconClient?.pair(pairingRequest)
            val peers = beaconClient?.getPeers()
            val isError = if (peers?.isNotEmpty() == true) 0 else 1
            result.success(mapOf("error" to isError))
        }
    }

    private fun removePeers(result: Result) {
        CoroutineScope(Dispatchers.IO).launch {
            beaconClient?.removeAllPeers()
            val peers = beaconClient?.getPeers()
            val isError = if (peers?.isNotEmpty() == true) 1 else 0
            result.success(mapOf("error" to isError))
        }
    }

    private fun saveAwaitingRequest(message: BeaconMessage) {
        awaitingRequest = if (message is BeaconRequest) message else null
    }

    private fun removeAwaitingRequest() {
        awaitingRequest = null
    }

    companion object {
        fun exampleTezosAccount(network: TezosNetwork, client: BeaconClient<*>): TezosAccount =
            TezosAccount(
                "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9",
                "tz1Mg6uXUhJzuCh4dH2mdBdYBuaiVZCCZsak",
                network,
                client,
            )

        fun exampleSubstrateAccount(
            network: SubstrateNetwork,
            client: BeaconClient<*>
        ): SubstrateAccount = SubstrateAccount(
            "724867a19e4a9422ac85f3b9a7c4bf5ccf12c2df60d858b216b81329df716535",
            "13aqy7vzMjuS2Nd6TYahHHetGt7dTgaqijT6Tpw3NS2MDFug",
            network,
            client,
        )
    }
}