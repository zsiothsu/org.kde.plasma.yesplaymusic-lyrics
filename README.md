# yesplaymusic-lyric

## 前言
作为重度网易云用户，YesPlayMusic 大概是我能在linux上找到的最好的播放器了，但是歌词显示一直是个痛点。本人平常主力机是Archlinux，桌面环境是kde，有啥需求当然是直接在aur里面找，但找到的桌面歌词软件都有这样那样的bug，实在不尽人意。
正巧昨日在贴吧刷到了@LiYulin大佬为kde做的[插件](https://github.com/LiYulin-s/org.kde.plasma.ypm-lyrics)，是用python后端加上qml前端编写的，于是想着能不能把这后端也去了。于是便产生了这个小项目。解析歌词的部分使用了[js-lyrics](https://github.com/frank-deng/js-lyrics)库

## 原理
YesPlayMusic在运行时会开放两个api获取歌曲信息，一个是`http://127.0.0.1:27232/player`用来获取基本信息，另一个是`http://127.0.0.1:10754/lyric?id=`用来获取歌词，两个api的返回值如下:

```json
/* http://127.0.0.1:27232/player */
{
    "currentTrack": {
    "name": "broKen NIGHT",
    "id": 476081900,
    "pst": 0,
    "t": 0,
    "ar": [{
        "id": 16152,
        "name": "Aimer",
        "tns": [],
        "alias": []
    }],
    "alia": ["PS Vitaゲーム「Fate/hollow ataraxia」OPテーマ"],
    "pop": 40,
    ......
    "progress":61.662793
}
```

```json
/* http://127.0.0.1:10754/lyric?id=476081900 */
{
     "sgc": false,
     "sfy": false,
     "qfy": false,
     "transUser": {
         "id": 2090794,
         "status": 99,
         "demand": 1,
         "userid": 59957287,
         "nickname": "虎纹鲨鱼子",
         "uptime": 1493869287084
     },
     "lyricUser": {
         "id": 2090785,
         "status": 99,
         "demand": 0,
         "userid": 59957287,
         "nickname": "虎纹鲨鱼子",
         "uptime": 1493869287084
     },
     "lrc": {
         "version": 16,
         "lyric": "[00:19.83]流れる星(ひかり)を\n[00:18.62]\n[00:26.19]ただ 重ねる指を\n"
     },
     "klyric": {
         "version": 0,
         "lyric": ""
     },
     "tlyric": {
         "version": 7,
         "lyric": "[by:虎纹鲨鱼子]\n[00:11.13]\n[00:19.83]向着流星祈愿\n[00:26.19]看，只要双手合十\n"
     },
     "romalrc": {
         "version": 4,
         "lyric": "[by:虎纹鲨鱼子]\n[00:11.13]\n[00:19.83]na ga re ru ho shi wo\n[00:26.19]ta da ka sa ne ru yu bi wo\n"
     },
     "code": 200
 }
```

## 安装
```shell
git clone https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics
cp -r org.kde.plasma.yesplaymusic-lyrics ~/.local/share/plasma/plasmoids/org.kde.plasma.yesplaymusic-lyrics
```