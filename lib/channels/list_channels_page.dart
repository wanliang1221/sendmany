import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sendmany/channels/create_channel_page.dart';
import 'package:sendmany/common/constants.dart';
import 'package:sendmany/common/models/models.dart';
import 'package:sendmany/common/widgets/charts/charts.dart';
import 'package:sendmany/common/widgets/widgets.dart';
import 'package:sendmany/wallet/balance/bloc/bloc.dart';

import 'display_channel_info_page.dart';
import 'subscribe_channel_events/bloc/bloc.dart';

class ListChannelsPage extends StatefulWidget {
  @override
  _ListChannelsPageState createState() => _ListChannelsPageState();

  static Widget buildFAB(
    BuildContext context,
    SubscribeChannelEventsBloc bloc,
  ) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return BlocProvider.value(value: bloc, child: CreateChannelPage());
          }),
        );
      },
    );
  }
}

class _ListChannelsPageState extends State<ListChannelsPage> {
  int _blockHeight = 0;
  StreamSubscription _sub;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<SubscribeChannelEventsBloc>(context),
      builder: (BuildContext context, SubscribeChannelEventsState state) {
        if (state is SubscribeChannelLoadingState) {
          return TranslatedText('network.loading');
        } else if (state is ChannelsUpdatedState) {
          var length = state.channels.length;
          var channels = state.channels;

          return ListView.builder(
            itemCount: length,
            itemBuilder: (context, i) {
              var channel = channels[i];

              if (channel == null && i != 0) {
                return Divider();
              }

              if (channel is EstablishedChannel) {
                return ListTile(
                  onTap: () => _openChannelPopup(channel),
                  leading: _buildIcon(channel),
                  title: _buildTitleColumn(channel),
                  dense: true,
                );
              } else if (channel is PendingOpenChannel) {
                return _buildOpenPendingListTile(channel);
              } else if (channel is PendingClosingChannel) {
                return _buildPendingCloseListTile(channel);
              } else if (channel is PendingForceClosingChannel) {
                return _buildPendingForceCloseListTile(channel);
              } else if (channel is WaitingCloseChannel) {
                return _buildWaitingCloseChannel(channel);
              } else if (channel == null && i > 0) {
                return Divider();
              } else if (channel == null && i == 0) {
                return Container();
              } else {
                return Text('Unknown Channel Type: $channel');
              }
            },
          );
        }
        return Text('Unknown State? $state');
      },
    );
  }

  @override
  void dispose() {
    if (_sub != null) {
      _sub.cancel();
      _sub = null;
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sub = BlocProvider.of<LnInfoBloc>(context).listen((LnInfoState state) {
      if (state is LnInfoStateLoadingFinished &&
          state.infoResponse.blockHeight != _blockHeight) {
        setState(() {
          _blockHeight = state.infoResponse.blockHeight;
        });
      }
    });
  }

  FlatLineChart _buildFlatLineChart(EstablishedChannel channel) {
    var total =
        channel.localBalance.toDouble() + channel.remoteBalance.toDouble();
    var sections = <ChartSectionInput>[
      ChartSectionInput(channel.localBalance.toDouble(), sendManyLocalBalance),
      ChartSectionInput(
        channel.remoteBalance.toDouble(),
        sendManyRemoteBalance,
      ),
    ];

    return FlatLineChart(
      values: sections,
      total: total,
      strokeWidth: 2,
    );
  }

  Icon _buildIcon(EstablishedChannel channel) {
    return Icon(
      channel.active ? Icons.check_circle : Icons.error_outline,
      color: channel.active ? Colors.green : sendManyYellow500,
    );
  }

  ListTile _buildOpenPendingListTile(PendingOpenChannel channel) {
    var theme = Theme.of(context);
    return ListTile(
      leading: Icon(MdiIcons.plusNetwork, color: Colors.green),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.open.opening',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: Text(
                  channel.channel.channelPoint.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.open.confirmations',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: Text(channel.confirmationHeight.toString()),
              ),
              TranslatedText(
                'channels.capacity',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(child: MoneyValueView(amount: channel.channel.capacity)),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _buildPendingCloseListTile(PendingClosingChannel channel) {
    var theme = Theme.of(context);

    return ListTile(
      leading: Icon(MdiIcons.minusNetwork, color: Colors.red),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.closing',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: Text(
                  channel.channel.channelPoint.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.receive_amt',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: MoneyValueView(amount: channel.channel.localBalance),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _buildPendingForceCloseListTile(PendingForceClosingChannel channel) {
    var theme = Theme.of(context);

    return ListTile(
      leading: Icon(MdiIcons.minusNetwork, color: Colors.red),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.force_closing',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: Text(
                  channel.channel.channelPoint.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.receive_amt',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: MoneyValueView(amount: channel.channel.localBalance),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _buildTitleColumn(EstablishedChannel channel) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: TranslatedText(
                'node.alias',
                style: theme.textTheme.caption,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32.0,
              ),
              child: channel.remoteNodeInfo == null
                  ? Text('Node info not found')
                  : Text(channel.remoteNodeInfo.node.alias),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: _buildFlatLineChart(channel),
        ),
        Row(
          children: <Widget>[
            TranslatedText('channels.local', style: theme.textTheme.caption),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: MoneyValueView(amount: channel.localBalance),
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: TranslatedText(
                'channels.remote',
                style: theme.textTheme.caption,
              ),
            ),
            MoneyValueView(amount: channel.remoteBalance),
          ],
        ),
      ],
    );
  }

  ListTile _buildWaitingCloseChannel(WaitingCloseChannel channel) {
    var theme = Theme.of(context);

    return ListTile(
      leading: Icon(MdiIcons.minusNetwork, color: Colors.red),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.waiting_close',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(
                child: Text(
                  channel.channel.channelPoint.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TranslatedText(
                'channels.close.limbo_balance',
                style: theme.textTheme.caption,
              ),
              SizedBox(width: defaultHorizontalWhiteSpace),
              Expanded(child: MoneyValueView(amount: channel.limboBalance)),
            ],
          ),
        ],
      ),
    );
  }

  void _openChannelPopup(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return DisplayChannelInfoPage(channel);
      }),
    );
  }
}
