import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../apis/article.dart';

class PostPage1 extends StatefulWidget {
  const PostPage1({super.key, });

  @override
  State<StatefulWidget> createState() => _PostPage1State();
}

class _PostPage1State extends State<PostPage1> {
  // text input
  final TextEditingController _textCtl = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  final List<File> _selectImgs = []; // 选择的图片列表

  final  List<String> _uploadedImageIds = []; // 已上传文件的id列表

  bool _isUploading = false;
  bool _isPublishing = false;


  @override
  void dispose() {
    _textCtl.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }
  // 图片选择
  Future<void> _pickImages() async{
    try {
      final remainCount = 9 - _selectImgs.length;
      if(remainCount <= 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("最多选择9张")),
        );
        return;
      }
      final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: remainCount,
          requestType: RequestType.image,
          themeColor: Color(0xff9900)
        )
      );
      if(selectedAssets== null || selectedAssets.isEmpty) return;
      final List<File> newImages= [];
      for(final asset in selectedAssets) {
        final File? imageFile = await asset.file;
        if(imageFile != null){
          newImages.add(imageFile);
        }
      }
      if(newImages.isNotEmpty && mounted) {
        setState(() {
          _selectImgs.addAll(newImages);
        });
      }

    } catch (e){
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("选择图片失败：${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // 删除图片
  _removeImage(int index) {
    setState(() {
      _selectImgs.removeAt(index);
      if(index < _uploadedImageIds.length) {
        _uploadedImageIds.removeAt(index);
      }
    });
  }
  // 上传图片到服务器
  Future<List<String>> _uploadImages() async {
    if(_selectImgs.isEmpty) return [];
    setState(() {
      _isUploading = true;
    });
    final List<String> imageIds = [];

    try {
      for(final imageFile in _selectImgs) {
        final res = await  ArticleApi.uploadImage(imageFile);
        imageIds.add(res.data!.imageId);
      }
      return imageIds;
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("图片上传失败:$e"),
            action: SnackBarAction(label: "上传失败", onPressed: () {  },)
          )
        );
      }
      rethrow;
    } finally {
      if(mounted) {
        setState(() {
          _isUploading= false;
        });
      }
    }
  }
  // 发布UGC内容
  Future<void> _publishArticle() async{
    final contentText = _textCtl.text.trim();
    if(contentText.isEmpty && _selectImgs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入内容、图片'),)
      );
      return;
    }
    setState(() {
      _isPublishing = true;
    });
    try {
      // 图片上传
      List<String> imageIds = [];

      imageIds = await _uploadImages();

      // UGC内容上传
      final res = await ArticleApi.createArticle(
        title: contentText.length > 50 ? contentText.substring(0, 50): contentText, 
        content: contentText,
        imageIds: imageIds
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
        ),
      );
      
      // 2秒后返回上一页
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()),),
      );
    } finally {
      if(mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }
  // 绘制图片渲染
  Widget _imageGrid({crossAxisCount = 3, spacing = 8.0}) {
    return Container(
      padding: EdgeInsets.all(16),
      child:GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        itemCount: _selectImgs.length + (_selectImgs.length < 9 ? 1: 0),
        itemBuilder: (context, index) {
          if(index == _selectImgs.length ) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: Colors.grey, size: 32),
              )
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectImgs[index],
                  fit: BoxFit.cover,
                )
              ),
              Positioned(
                top: 4, 
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[5],
                      shape: BoxShape.rectangle
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16)
                  )
                )
              )
            ],
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
      title: const Text("发布内容"),
      actions:[
        if(_isPublishing) 
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor:  AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 34, 31, 31)),)
            )
          )
        else
          TextButton(
            onPressed: _isUploading ? null : _publishArticle,
            child: Text("发布", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 14),)
          )
      ]
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textCtl,
                  focusNode:_textFocusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "分享你的看法",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                // 图片网格
                _imageGrid(),
              ],
            )
          ),
        ),
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   decoration: BoxDecoration(
        //     color: const Color.fromARGB(255, 238, 234, 234),
        //   ),
        //   child: Row(
        //     children: [
        //       IconButton(
        //         onPressed: _selectImgs.length > 9 ? null : _pickImages,
        //         icon: Icon(Icons.photo_library)
        //       ),
        //       SizedBox(width: 8,),
        //       if(_isUploading)
        //         Padding(
        //           padding: EdgeInsets.only(right: 9.0),
        //           child: SizedBox(
        //             width: 18,
        //             height: 18,
        //             child: CircularProgressIndicator(strokeWidth: 2,)
        //           )
        //         ),
        //     ],
        //   )
        // )
      ]
    )
   );
  }
}