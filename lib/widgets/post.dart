import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_two_record/constatns/common_size.dart';
import 'package:instagram_two_record/constatns/screen_size.dart';
import 'package:instagram_two_record/models/firestore/post_model.dart';
import 'package:instagram_two_record/models/user_model_state.dart';
import 'package:instagram_two_record/repo/image_network_repository.dart';
import 'package:instagram_two_record/repo/post_network_repository.dart';
import 'package:instagram_two_record/screens/comments_screen.dart';
import 'package:instagram_two_record/widgets/comment.dart';
import 'package:instagram_two_record/widgets/my_progress_indicator.dart';
import 'package:instagram_two_record/widgets/rounded_avatar.dart';
import 'package:provider/provider.dart';

class Post extends StatelessWidget {
  final PostModel postModel;

  Post(
    this.postModel, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _postHeader(),
        _postImage(),
        _postActions(context),
        _postLikes(),
        _postCaption(),
        _lastComment(),
        _moreComments(context),
      ],
    );
  }

  Widget _postCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: common_gap, vertical: common_xxs_gap),
      child: Comment(
        showImage: false,
        username: postModel.username,
        text: postModel.caption,
      ),
    );
  }

  Widget _lastComment() {
    return Padding(
      padding: const EdgeInsets.only(
          left: common_gap, right: common_gap, top: common_xxs_gap),
      child: Comment(
        showImage: false,
        username: postModel.lastCommentor,
        text: postModel.lastComment,
      ),
    );
  }

  Padding _postLikes() {
    return Padding(
      padding: const EdgeInsets.only(left: common_gap),
      child: Text(
        '${postModel.numOfLikes == null ? 0 : postModel.numOfLikes.length} likes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Row _postActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
            icon: ImageIcon(AssetImage('assets/images/bookmark.png')),
            color: Colors.black87,
            onPressed: null),
        IconButton(
          icon: ImageIcon(AssetImage('assets/images/comment.png')),
          color: Colors.black87,
          onPressed: () {
            _goToComments(context);
          },
        ),
        IconButton(
            icon: ImageIcon(AssetImage('assets/images/direct_message.png')),
            color: Colors.black87,
            onPressed: null),
        Spacer(),
        Consumer<UserModelState>(
          builder: (BuildContext context, UserModelState userModelState,
              Widget child) {
            return IconButton(
                icon: ImageIcon(
                  AssetImage(postModel.numOfLikes
                          .contains(userModelState.userModel.userKey)
                      ? 'assets/images/heart_selected.png'
                      : 'assets/images/heart.png'),
                  color: Colors.redAccent,
                ),
                color: Colors.black87,
                onPressed: () {
                  postNetworkRepository.toggleLike(
                      postModel.postKey, userModelState.userModel.userKey);
                });
          },
        ),
      ],
    );
  }

  Widget _postHeader() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(common_xxs_gap),
          child: RoundedAvatar(),
        ),
        Expanded(child: Text(postModel.username)),
        IconButton(
            onPressed: null,
            icon: Icon(Icons.more_horiz, color: Colors.black87)),
      ],
    );
  }

  Widget _postImage() {
    Widget progress = MyProgressIndicator(
      containerSize: size.width,
    );
    return CachedNetworkImage(
      imageUrl: postModel.postImg,
      placeholder: (BuildContext context, String url) {
        //context??? string??? ???????????? ??????????????? ????????? ????????? ?????????
        return progress;
      },
      imageBuilder: (BuildContext context, ImageProvider imageProvider) {
        return AspectRatio(
          aspectRatio: 1.5, //??????????????? ?????? ?????? (????????? ???????????? 1.5??? ??????)
          child: Container(
            decoration: BoxDecoration(
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.cover)),
          ),
        );
      },
    );
  }

  _moreComments(BuildContext context) {
    return Visibility(
      visible:
          (postModel.numOfComments != null || postModel.numOfComments >= 2),
      child: GestureDetector(
        onTap: () {
          _goToComments(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: common_gap,
          ),
          child: Text("${postModel.numOfComments - 1} more comments..."),
        ),
      ),
    );
  }

  _goToComments(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CommentsScreen(postModel.postKey);
    }));
  }
}
