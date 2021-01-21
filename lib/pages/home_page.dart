import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/pages/search_page.dart';
import 'package:flutter_trip/pages/speak_page.dart';
import 'package:flutter_trip/util/navigator_util.dart';
import 'package:flutter_trip/widget/grid_nav.dart';
import 'package:flutter_trip/widget/loading_container.dart';
import 'package:flutter_trip/widget/local_nav.dart';
import 'package:flutter_trip/widget/sales_box.dart';
import 'package:flutter_trip/widget/search_bar.dart';
import 'package:flutter_trip/widget/sub_nav.dart';
import 'package:flutter_trip/widget/web_view.dart';

const int APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = '网红打卡地 景点 酒店 美食';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  double _appBarAlpha = 0;
  List<CommonModel> localNavList = [];
  List<CommonModel> bannerList = [];
  List<CommonModel> subNavList = [];
  GridNavModel gridNavModel;
  SalesBoxModel salesBoxModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  _onScroll(offset) {
    // change alpha of appBar while scrolling
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      _appBarAlpha = alpha;
    });
  }

  Future<Null> _handleRefresh() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
        bannerList = model.bannerList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBoxModel = model.salesBox;
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: LoadingContainer(
          isLoading: _loading,
          child: Stack(children: <Widget>[
            MediaQuery.removePadding(
                // remove top padding for phones with a '刘海'
                removeTop: true,
                context: context,
                child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: NotificationListener<ScrollNotification>(
                      // use this widget to listen vertical scroll
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification &&
                            scrollNotification.depth == 0) {
                          // scrollNotification.depth == 0, means only function on first child, dfs order
                          _onScroll(scrollNotification.metrics.pixels);
                        }
                        // if using RefreshIndicator, should not return true.
                        // need return false or delete this return statement
                        // because parent also need to catch this scroll event
                        return false;
                      },
                      child: _listView,
                    ))),
            // upper widgets in Stack will be put in lower position
            _appBar,
          ]),
        ));
  }

  Widget get _appBar {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              // the gradient at the top of app bar. from dark to light.
              gradient: LinearGradient(
            colors: [Color(0x66000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80.0,
            decoration: BoxDecoration(
              color:
                  Color.fromARGB((_appBarAlpha * 255).toInt(), 255, 255, 255),
            ),
            child: SearchBar(
              searchBarType: _appBarAlpha > 0.2
                  ? SearchBarType.homeLight
                  : SearchBarType.home,
              inputBoxClick: _jumpToSearch,
              speakClick: _jumpToSpeak,
              defaultText: SEARCH_BAR_DEFAULT_TEXT,
              leftButtonClick: () {},
            ),
          ),
        ),
        // shadow area under appbar. height = 4.
        Container(
          height: _appBarAlpha > 0.2 ? 2 : 0,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)]),
        ),
      ],
    );
  }

  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              CommonModel model = bannerList[index];
              NavigatorUtil.push(context, WebView(
                url: model.url,
                statusBarColor: model.statusBarColor,
                hideAppBar: model.hideAppBar,
              ));
            },
            child: Image.network(
              bannerList[index].icon,
              fit: BoxFit.fill,
            ),
          );
        },
        pagination: SwiperPagination(),
      ),
    );
  }

  Widget get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
          child: LocalNav(localNavList: localNavList),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: GridNav(gridNavModel: gridNavModel),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child: SubNav(subNavList: subNavList),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 400),
          child: SalesBox(salesBox: salesBoxModel),
        ),
      ],
    );
  }

  _jumpToSearch() {
    NavigatorUtil.push(context,SearchPage(hint: SEARCH_BAR_DEFAULT_TEXT) );
  }

  _jumpToSpeak() {
    NavigatorUtil.push(context,SpeakPage());
  }

  @override
  bool get wantKeepAlive => true;
}
