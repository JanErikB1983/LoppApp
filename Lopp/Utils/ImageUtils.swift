// Filnavn: ImageUtils.swift
import UIKit

enum ImageUtils {
  static func jpegDataScaled(_ image: UIImage, maxWidth: CGFloat = 1280, quality: CGFloat = 0.8) -> Data? {
    let scale = min(1, maxWidth / max(image.size.width, 1))
    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resized?.jpegData(compressionQuality: quality)
  }
}
