# MVIMG2Live

将安卓手机拍摄的MVIMG格式实况照片转换为苹果Live Photo

## 使用方法

1. 安装`exiftool`和`uuidgen`
2. 新建文件`~/.exiftool_config`内容如下
```
%Image::ExifTool::UserDefined = (
    'Image::ExifTool::Exif::Main' => {
        0x927c => {
            Name => 'MakerNoteApple',
            Format => 'undef',
            Groups => { 0 => 'ExifIFD' },
            Writable => 'undef',
        },
    },
);
```
4. 确保`start.sh`与`livephoto`位于待转换照片路径下，待转换照片应以MVIMG开头。
5. 执行`start.sh`
6. 为不影响后续使用`exiftool`解析苹果手机拍摄照片EXIF信息时的显示，可选择删除`~/.exiftool_config`

注意：本文件只进行最基本的转换，没有将照片在视频中的时间点信息同步。

**警告：执行可执行文件代表你已经完全理解文件的内容和操作，已备份原始照片文件，接受原始照片文件受到任何影响，包括被彻底删除。**

Note: This file only performs the most basic conversion and does not synchronize the timing information of the photos in the video.

**Warning: Executing the executable file signifies that you fully understand the contents and operations of the file, have backed up the original photo files, and accept any impact on the original photo files, including their complete deletion.**

---

## 原理

安卓机的实况照片普遍采用MVIMG格式，即将视频拼接在jpeg中；而苹果的Live Photo是独立的两个文件，通过照片的EXIF与视频元数据中的特定字段，将文件对进行匹配并标记相关信息，详细原理可见[这篇资料](https://www.limit-point.com/blog/2018/live-photos/)。

这些元数据中有一个关键字段`Content Identifier`：一个UUID，用于唯一地确定照片视频对。只要照片与视频有相同的`Content Identifier`，即便其他元数据都没有，也能在macOS下被Photo应用识别为Live Photo并正确导入。这也是在iPhone的Google Photo中下载MVIMG的实况照片时Google Photo的处理方式。

因此本仓库的文件将照片与视频分离后，分别向其写入了相同的`Content Identifier`，从而实现了MVIMG向Live Photo的转换。

视频的元数据可以直接用`exiftool`进行修改，而苹果照片的`Content Identifier`字段存储在EXIF中`MakerNote`部分，无法直接用`exiftool`写入。通过观察Google Photo转换后的Live Photo，注意到其`MakerNote`字段的二进制格式如下：
<img width="1021" alt="image" src="https://github.com/user-attachments/assets/d7864113-b8a4-420f-afa7-22c8a69add85" />
因此直接模仿其格式，更换其中的UUID并注入到照片中即可。
