import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/travel_dao.dart';
import 'package:flutter_trip/model/travel_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_trip/util/navigator_util.dart';
import 'package:flutter_trip/widget/loading_container.dart';
import 'package:flutter_trip/widget/web_view.dart';

const String _TRAVEL_URL =
    'https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031014111431397988&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_platform=H5';
const int PAGE_SIZE = 10;

class TravelTabPage extends StatefulWidget {
  final String travelUrl;
  final String groupChannelCode;

  const TravelTabPage({Key key, this.travelUrl, this.groupChannelCode})
      : super(key: key);

  @override
  _TravelTabPageState createState() => _TravelTabPageState();
}

class _TravelTabPageState extends State<TravelTabPage>
    with AutomaticKeepAliveClientMixin {
  List<TravelItem> travelItems;
  int pageIndex = 1;
  bool _loading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData({loadMore = false}) {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }
    TravelDao.fetch(widget.travelUrl ?? _TRAVEL_URL, widget.groupChannelCode,
            pageIndex, PAGE_SIZE)
        .then((TravelItemModel model) {
      _loading = false;
      setState(() {
        List<TravelItem> items = _filterItems(model.resultList);
        if (travelItems != null) {
          travelItems.addAll(items);
        } else {
          travelItems = items;
        }
      });
    }).catchError((e) {
      _loading = false;
      print(e);
    });
  }

  List<TravelItem> _filterItems(List<TravelItem> resultList) {
    if (resultList == null) {
      return [];
    }
    List<TravelItem> filterItems = [];
    resultList.forEach((item) {
      if (item.article != null) {
        filterItems.add(item);
      }
    });
    return filterItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingContainer(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: StaggeredGridView.countBuilder(
              controller: _scrollController,
              crossAxisCount: 4,
              itemCount: travelItems?.length ?? 0,
              itemBuilder: (BuildContext context, int index) =>
                  _TravelItem(index: index, item: travelItems[index]),
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  // with AutomaticKeepAliveClientMixin
  // current page is to be kept alive
  // 避免tab之间滑动，导致page重绘。缺点，如果tab多，会占用很多memory
  bool get wantKeepAlive => true;

  Future<Null> _handleRefresh() async {
    _loadData();
    return null;
  }
}

class _TravelItem extends StatelessWidget {
  final TravelItem item;
  final int index;

  const _TravelItem({Key key, this.item, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.article.urls != null && item.article.urls.length > 0) {
          NavigatorUtil.push(context, WebView(
            url: item.article.urls[0].h5Url,
            title: '详情',
          ));
        }
      },
      child: Card(
        child: PhysicalModel(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(5),
          child: Column(
            // all text start from left, not align center
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _itemImage(),
              Container(
                padding: EdgeInsets.all(4),
                child: Text(
                  item.article.articleTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              _infoText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemImage() {
    return Stack(
      children: [
        Image.network(item.article.images[0]?.dynamicUrl),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                LimitedBox(
                  maxWidth: 130,
                  child: Text(
                    _poiName(),
                    maxLines: 1,
                    // 省略号
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _poiName() {
    return item.article.pois == null || item.article.pois.length == 0
        ? '未知'
        : item.article.pois[0]?.poiName ?? '未知';
  }

  Widget _infoText() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PhysicalModel(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.article.author?.coverImage?.dynamicUrl,
                  width: 24,
                  height: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  item.article.author?.nickName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.thumb_up,
                size: 14,
                color: Colors.grey,
              ),
              Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.article.likeCount.toString(),
                  style: TextStyle(fontSize: 10),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
