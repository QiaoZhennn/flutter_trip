import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/search_dao.dart';
import 'package:flutter_trip/model/search_model.dart';
import 'package:flutter_trip/pages/speak_page.dart';
import 'package:flutter_trip/util/navigator_util.dart';
import 'package:flutter_trip/widget/search_bar.dart';
import 'package:flutter_trip/widget/web_view.dart';

const URL =
    'https://m.ctrip.com/restapi/h5api/globalsearch/search?source=mobileweb&action=mobileweb&keyword=';
const TYPES = [
  'channelgroup',
  'channelgs',
  'channelplane',
  'channeltrain',
  'cruise',
  'district',
  'huodong',
  'shop',
  'sight',
  'ticket',
  'travelgroup',
];

class SearchPage extends StatefulWidget {
  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;

  const SearchPage(
      {Key key, this.hideLeft, this.searchUrl = URL, this.keyword, this.hint})
      : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel searchModel;
  String keyword;
  String showText = '';

  @override
  void initState() {
    if (widget.keyword != null) {
      _onTextChanged(widget.keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        _appBar(),
        // use this to remove Padding
        MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Expanded(
            // ListView must be assigned a height. Can use Expanded to let ListView
            // take up all vertical spare space
            flex: 1,
            child: ListView.builder(
              itemCount: searchModel?.data?.length ?? 0,
              itemBuilder: (BuildContext context, int position) {
                return _item(position);
              },
            ),
          ),
        ),
      ],
    ));
  }

  _onTextChanged(text) {
    keyword = text;
    if (text.length == 0) {
      setState(() {
        searchModel = null;
      });
      return;
    }
    String url = widget.searchUrl + text;
    SearchDao.fetch(url, text).then((SearchModel model) {
      // only draw page when current input text is equal to the
      // context the backend returned. An optimization procedure
      if (model.keyword == keyword) {
        setState(() {
          searchModel = model;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  _appBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 20),
            height: 80,
            decoration: BoxDecoration(color: Colors.white),
            child: SearchBar(
              hideLeft: widget.hideLeft,
              defaultText: widget.keyword,
              hint: widget.hint,
              speakClick: _jumpToSpeak,
              leftButtonClick: () {
                Navigator.pop(context);
              },
              onChanged: _onTextChanged,
            ),
          ),
        )
      ],
    );
  }

  void _jumpToSpeak() {
    NavigatorUtil.push(context, SpeakPage());
  }

  _item(int position) {
    if (null == searchModel || null == searchModel.data) return null;
    SearchItem item = searchModel.data[position];
    return GestureDetector(
      onTap: () {
        NavigatorUtil.push(context, WebView(url: item.url, title: '详情'));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.3, color: Colors.grey),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(1),
              child: Image(
                height: 26,
                width: 26,
                image: AssetImage(
                  _typeImage(item.type),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 300,
                  child: _title(item),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 5),
                  child: _subTitle(item),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _typeImage(String type) {
    if (null == type) {
      return 'images\\type_travelgroup.png';
    }
    String path = 'travelgroup';
    for (final val in TYPES) {
      if (type.contains(val)) {
        path = val;
        break;
      }
    }
    return 'images\\type_$path.png';
  }

  _title(SearchItem item) {
    if (null == item) return null;
    List<TextSpan> spans = [];
    spans.addAll(_keywordTextSpans(item.word, searchModel.keyword));
    spans.add(TextSpan(
        text: ' ' + (item.districtname ?? '') + (item.zonename ?? ''),
        style: TextStyle(fontSize: 16, color: Colors.grey)));
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  _subTitle(SearchItem item) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: item.price ?? '',
          style: TextStyle(fontSize: 16, color: Colors.orange),
        ),
        TextSpan(
          text: ' ' + (item.star ?? ''),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
      ]),
    );
  }

  _keywordTextSpans(String word, String keyword) {
    List<TextSpan> spans = [];
    if (null == word || word.length == 0 || null == keyword) return spans;
    List<String> arr = word.split(keyword);
    TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange);
    // highlight the keyword
    // 'wordwoc'.split('w') => [, ord, oc], length = 3, keyword 'w' appears in comma position
    for (int i = 0; i < arr.length; ++i) {
      if ((i + 1) % 2 == 0) {
        spans.add(TextSpan(text: keyword, style: keywordStyle));
      }
      String val = arr[i];
      if (null != val && val.length > 0) {
        spans.add(TextSpan(text: val, style: normalStyle));
      }
    }
    return spans;
  }
}
