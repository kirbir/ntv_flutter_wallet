import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/data/rpc_config.dart';

class RpcSelector extends StatefulWidget {
  final String currentNetwork;
  final bool isHealthy;
  final Function(String) onNetworkChanged;

  const RpcSelector({
    super.key,
    required this.currentNetwork,
    required this.isHealthy,
    required this.onNetworkChanged,
  });

  @override
  State<RpcSelector> createState() => _RpcSelectorState();
}

class _RpcSelectorState extends State<RpcSelector> {
  Color get rpcColor =>
      widget.isHealthy ? Colors.greenAccent : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.lan_outlined, size: 25, color: rpcColor),
              DropdownButton<String>(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down_outlined),
                iconSize: 24,
                iconEnabledColor: Colors.white,
                value: widget.currentNetwork,
                items: RpcNetwork.labels
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Text(label),
                          ),
                        ))
                    .toList(),
                onChanged: (newNetwork) {
                  if (newNetwork != null) {
                    widget.onNetworkChanged(newNetwork);
                    
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
