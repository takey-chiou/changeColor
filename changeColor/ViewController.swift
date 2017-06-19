//
//  ViewController.swift
//  changeColor
//
//  Created by dachiou on 2017/1/24.
//  Copyright © 2017年 dachiou. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    var touchPosition:CGPoint?;
    var colorRGB256:[UInt8]?;
    var originalImage:UIImage?;
    var crossView:UIImageView!;
    var colorPosition = CGPoint(x: 0, y: 0);
    var gradientColor:[CGFloat]?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorGradientView: UIImageView!
    @IBOutlet weak var displayImageColor: UIView!
    @IBOutlet weak var chooseGradientColor: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screeBounds = UIScreen.main.bounds;
        print("螢幕大小\(screeBounds)");
        view.backgroundColor = UIColor.lightGray;
        imageView.image = UIImage(named: "profile");
        print(indicatorView.frame);
        //chooseGradientColor.clipsToBounds = true;
        //view.addSubview(indicatorView);
        indicatorView.center = imageView.center;
        
        //調色盤
        //先畫彩色
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components:[CGFloat] = [1.0, 0.0, 0.0, 1.0,
                                    1.0, 1.0, 0.0, 1.0,
                                    0.0, 1.0, 0.0, 1.0,
                                    0.0, 1.0, 1.0, 1.0,
                                    0.0, 0.0, 1.0, 1.0,
                                    1.0, 0.0, 1.0, 1.0,
                                    1.0, 0.0, 0.0, 1.0];
        let locations:[CGFloat] = [0.0, 0.16, 0.33, 0.50, 0.66, 0.82, 1.0];
        //let locations:[CGFloat] = [0.0, 1.0/7.0, 2.0/7.0, 3.0/7.0, 4.0/7.0, 5.0/7.0, 6.0/7.0, 1.0];
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: locations.count);
        
        UIGraphicsBeginImageContext(colorGradientView.frame.size);
        
        var context = UIGraphicsGetCurrentContext();
        
        print("顏色盤的frame:\(colorGradientView.frame)");
        
        context?.drawLinearGradient(gradient!, start: CGPoint(x:0.0,y:0.0), end: CGPoint(x:colorGradientView.frame.width*0.95,y:0.0), options: CGGradientDrawingOptions(rawValue: 0));
        
        context?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
    
        
        context?.fill(CGRect(x: colorGradientView.frame.width*0.95, y: 0.0, width: colorGradientView.frame.width*0.05, height: colorGradientView.frame.height));
 
        let paletteImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        //畫黑白
        let grayComponents:[CGFloat] = [1.0, 1.0, 1.0, 1.0,
                                        0.5, 0.5, 0.5, 1.0,
                                        0.0, 0.0, 0.0, 1.0];
        
        let grayLocations:[CGFloat] = [0.0, 0.5, 1.0];
        
        let grayGradient = CGGradient(colorSpace: colorSpace, colorComponents: grayComponents, locations: grayLocations, count: grayLocations.count);
        
        UIGraphicsBeginImageContext(colorGradientView.frame.size);
        
        context = UIGraphicsGetCurrentContext();
        
        context?.drawLinearGradient(grayGradient!, start: CGPoint(x:0.0,y:0.0), end: CGPoint(x:0.0,y:colorGradientView.frame.height), options: CGGradientDrawingOptions(rawValue: 0));
    
        //合成 彩色和黑白
        
        context?.setBlendMode(.multiply);
        //print(colorGradientView.frame);
        let cgRect = CGRect(x: 0, y: 0, width: colorGradientView.frame.size.width, height: colorGradientView.frame.size.height);
        //print(cgRect)
        context?.draw(paletteImage!.cgImage!, in: cgRect, byTiling: true);
        
        context!.saveGState();
        
        
        //將畫布顯示
        colorGradientView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        //顯示一個準心在顏色盤上
        
        print(colorGradientView.frame)
        print(colorGradientView.bounds)
        
        let reSize = CGSize(width: 15, height: 15);
        let crossImage = UIImage(named: "cross")?.reSizeImage(reSize: reSize);
        
        crossView = UIImageView(image: crossImage);
        crossView.frame.origin.x = colorGradientView.frame.origin.x;
        crossView.frame.origin.y = colorGradientView.frame.origin.y;
        print(crossView.frame)
    
        crossView.isUserInteractionEnabled = true;
        
        self.view.addSubview(crossView);
        let crossPan = UIPanGestureRecognizer(target: self, action: #selector(crossDidPan(gesture:)));
        crossPan.maximumNumberOfTouches = 1;
        crossPan.minimumNumberOfTouches = 1;
        crossView.addGestureRecognizer(crossPan)

        
    }
    
    
    @IBAction func camera(_ sender: UIButton) {
        self.callGetPhoneWithKind(1);
    }
    
    @IBAction func photo(_ sender: UIButton) {
        self.callGetPhoneWithKind(2)
    }

    //挑選圖片中的顏色
    @IBAction func calculate(_ sender: UIButton) {
        
        if touchPosition == nil {
            let alertController = UIAlertController(title: "步驟錯誤", message: "尚未選擇圖片中的顏色，請點選圖片中要更改的顏色", preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "確認", style: .default, handler: nil));
            self.present(alertController, animated: true, completion: nil);
        }else if !imageView.bounds.contains(touchPosition!){
            let alertController = UIAlertController(title: "步驟錯誤", message: "請點選位於圖片內的位置", preferredStyle: .alert);
            alertController.addAction(UIAlertAction(title: "確認", style: .default, handler: nil));
            self.present(alertController, animated: true, completion: nil);
        }else{
            let image = imageView.image!;
            originalImage = imageView.image;
            print("範圍是 \(imageView.bounds)");
            print("點選位置是 \(touchPosition!)");
            print("圖片寬 = \(image.size.width)");
            print("圖片高 = \(image.size.height)");
            let colorPositionX = (touchPosition?.x)! / imageView.bounds.width * image.size.width;
            let colorPosotionY = (touchPosition?.y)! / imageView.bounds.height * image.size.height;
            let cgPoint = CGPoint(x: colorPositionX, y: colorPosotionY);
            print("對應的圖片位置 \(cgPoint)");
            let colorRGB = image.getPixelColor(pos: cgPoint); // 0~1
            print(colorRGB);
            
            let markColor = UIColor(red: colorRGB[0], green: colorRGB[1], blue: colorRGB[2], alpha: colorRGB[3]);
            
            displayImageColor.backgroundColor = markColor;
            
            colorRGB256 = [];
            for i in 0...3{
            colorRGB256?.append(UInt8(Int(colorRGB[i]*255)));
            }
        }
    }
    
    //改變圖片中的顏色
    @IBAction func pixelWithSameColor(_ sender: UIButton) {
        
        if colorRGB256 == nil {
            print("請先選擇圖片中的顏色");
        }else if gradientColor == nil {
            print("請選擇欲變成的顏色");
        }else{
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.indicatorView.startAnimating();
                }
                let image = self.imageView.image!;
                var tempPixelData = self.getImageData(image: image);
                print("pixel數量：\(tempPixelData.count)");
                var pixelIndex:[Int] = [];
                var rgbError:[Int] = [];
                for i in 0..<tempPixelData.count/4{
                    var error = 0.0;
                    var temp = 0.0;
                    for j in 0...3{
                        temp = Double(tempPixelData[4*i+j]) - Double(self.colorRGB256![j]);
                        error = error + sqrt(pow(temp,2));
                        rgbError.append(Int(temp));
                    }
                    if error < 80 {
                        pixelIndex.append(i);
                    }
                }
                print("pixelIndex數量 = \(pixelIndex.count)");
        
                let coverRGB:[UInt8] = [UInt8(self.gradientColor![0]*255),UInt8(self.gradientColor![1]*255),UInt8(self.gradientColor![2]*255),UInt8(self.gradientColor![3]*255)];
        
                for i in 0 ..< pixelIndex.count{
                    for j in 0 ... 3{
                        var mixRGB = Int(coverRGB[j]) + rgbError[4*pixelIndex[i]+j];
                        if mixRGB < 0{
                            mixRGB = 0;
                        }else if mixRGB > 255{
                            mixRGB = 255;
                        }
                        tempPixelData[4*pixelIndex[i]+j] = UInt8(mixRGB);
                    }
                }
                print("tempPixelData數量 = \(tempPixelData.count)");
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let tempContext = CGContext(data: &tempPixelData,
                                        width: Int(image.size.width),
                                        height: Int(image.size.height),
                                        bitsPerComponent: 8,
                                        bytesPerRow: 4 * Int(image.size.width),
                                        space: colorSpace,
                                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            
                let outcgImage = tempContext?.makeImage();
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: outcgImage!);
                    self.indicatorView.stopAnimating();
                }
                }
        }
    }
    
    
    //還原圖片
    @IBAction func reduction(_ sender: UIBarButtonItem) {
        imageView.image = originalImage;
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPosition = touch.location(in: imageView);
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /// 開啟相機或相簿
    ///
    /// - Parameter kind: 1=相機,2=相簿
    func callGetPhoneWithKind(_ kind: Int) {
        let picker: UIImagePickerController = UIImagePickerController();
        switch kind {
        case 1:
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                picker.sourceType = UIImagePickerControllerSourceType.camera;
                picker.allowsEditing = true; // 可對照片作編輯
                picker.delegate = self; // 繼承UIImagePickerControllerDelegate , UINavigationControllerDelegate
                self.present(picker, animated: true, completion: nil);
            }else{
                print("沒有相機鏡頭......"); // 用 alertView.show
            }
        default:
            // 開啟相簿
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                picker.allowsEditing = true;
                picker.delegate = self;
                self.present(picker, animated: true, completion: nil);
            }
        }
    }

    // MARK: - Delegate
    // ---------------------------------------------------------------------
    /// 取得選取後的照片
    ///
    /// - Parameters:
    ///   - picker: pivker
    ///   - info: info
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil); // 關掉
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; //// 從Dictionary取出原始圖檔
    }
        // 圖片picker控制器任務結束回呼
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    func getImageData(image:UIImage) -> [UInt8]{
        let size = image.size;
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        let cgImage = image.cgImage;
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        return pixelData;
    }

    /////移動準心
    func crossDidPan(gesture:UIGestureRecognizer) {
        let point = gesture.location(in: self.view);
        if colorGradientView.frame.contains(point) == true{
            crossView.center = point;
            colorPosition.x = point.x - colorGradientView.frame.origin.x + 1;
            colorPosition.y = point.y - colorGradientView.frame.origin.y + 1;
            print(colorPosition);
            
            //顯示準心在色盤的顏色
            //
            gradientColor = colorGradientView.image?.getPixelColor(pos: colorPosition);
            chooseGradientColor.backgroundColor = UIColor(red: (gradientColor?[0])!, green: (gradientColor?[1])!, blue: (gradientColor?[2])!, alpha: (gradientColor?[3])!);
        }
    }
    
}


extension UIImage {
    func getPixelColor(pos: CGPoint) -> [CGFloat] {//uicolor
        let size = self.size;
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        let cgImage = self.cgImage;
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y-1)) + Int(pos.x-1)) * 4;
        
        let r = CGFloat(pixelData[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(pixelData[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(pixelData[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(pixelData[pixelInfo+3]) / CGFloat(255.0)

        return [r,g,b,a];
        //UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x:0,y: 0,width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

