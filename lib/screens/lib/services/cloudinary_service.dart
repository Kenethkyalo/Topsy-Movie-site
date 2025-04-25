// ignore: unused_import
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName = "djqgnqtym"; // Your Cloudinary cloud name
  final String uploadPreset = "movie_uploads"; // Replace with actual preset

  Future<String?> uploadImage(BuildContext context, XFile imageFile) async {
    try {
      String uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      MultipartFile multipartFile;

      if (kIsWeb) {
        Uint8List bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: "upload.jpg");
      } else {
        multipartFile = await MultipartFile.fromFile(imageFile.path);
      }

      FormData formData = FormData.fromMap({
        "file": multipartFile,
        "upload_preset":
            uploadPreset, // Using upload preset (no API key/secret needed)
      });

      Response response = await Dio().post(
        uploadUrl,
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200) {
        return response.data['secure_url']; // ✅ Return Cloudinary image URL
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cloudinary Error: ${response.statusMessage}"),
          ),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cloudinary Upload Error: $e")));
      return null;
    }
  }
}
