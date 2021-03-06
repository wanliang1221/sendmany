import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendmany/common/utils.dart';
import 'package:sendmany/common/widgets/widgets.dart';
import 'package:sendmany/wallet/balance/bloc/bloc.dart';

class NodeOverviewWidget extends StatefulWidget {
  @override
  _NodeOverviewWidgetState createState() => _NodeOverviewWidgetState();
}

class _NodeOverviewWidgetState extends State<NodeOverviewWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<LnInfoBloc>(context),
      builder: (BuildContext context, LnInfoState state) {
        if (state is LnInfoStateLoading) {
          return TranslatedText('network.loading');
        } else if (state is LnInfoStateLoadingFinished) {
          return LocalNodeInfoWidget(
              state.infoResponse, tr(context, 'node.info'));
        }
        return Text('Unknown State? $state');
      },
    );
  }
}
