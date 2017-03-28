//
//  ViewController.swift
//  Project13
//
//  Created by Mehmet Sadıç on 26/03/2017.
//  Copyright © 2017 Mehmet Sadıç. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var intensity: UISlider!
  
  var currentImage: UIImage!
  var context: CIContext!
  var currentFilter: CIFilter!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    context = CIContext()
    currentFilter = CIFilter(name: "CISepiaTone")
    
    // Set title to the name of current filter
    title = "Filter: \(currentFilter.name)"
    
    // By tapping on + button we we want to bring image library to pick image
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(chooseImage))
    
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // Do operations here after picking the image
    
    // Check that there is an image selected. Return otherwise
    guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
    
    // Dismiss the view after selecting image
    dismiss(animated: true, completion: nil)
    currentImage = image
    
    // convert the image into CIImage format so that it can be edited
    if let beginImage = CIImage(image: currentImage) {
      
      // apply the filter to selected ciimage
      currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
      processImage()
    }
    
  }
  
  
  
  func chooseImage() {
    // pick an image from photo library
    
    // Create an image picker controller
    let picker = UIImagePickerController()
    
    // we allow image to be editable
    picker.allowsEditing = true
    
    // View controller is the delegate of picker instance
    picker.delegate = self
    
    // present the picker so that it is seen on screen
    present(picker, animated: true)
  }
  
  private func processImage() {
    // Apply filter to the image
    
    // All the input keys used by currentFilter
    let inputKeys = currentFilter.inputKeys
    
    if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
    
    let centerVector = CIVector(x: currentImage.size.width / 2.0, y: currentImage.size.height / 2.0)
    if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(centerVector, forKey: kCIInputCenterKey) }
    if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 100, forKey: kCIInputRadiusKey) }
    if inputKeys.contains(kCIInputAngleKey) { currentFilter.setValue(intensity.value * Float.pi, forKey: kCIInputAngleKey) }
    if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 20, forKey: kCIInputScaleKey) }
    
    if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
      let processedImage = UIImage(cgImage: cgimg)
      imageView.image = processedImage
    }
  }
  
  private func chooseFilter(alert: UIAlertAction) {
    // Choose a different filter
    
    // Set the title of the action as the new filter name
    currentFilter = CIFilter(name: alert.title!)
  
    guard currentFilter != nil else { return }
    
    // Set title to the name of current filter
    title = "Filter: \(currentFilter.name)"
    
    // convert the image into CIImage format so that it can be edited
    guard currentImage != nil else { return }
    if let beginImage = CIImage(image: currentImage) {
      
      // apply the filter to selected ciimage
      currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
      processImage()
    }
  }
  
  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    var ac = UIAlertController()
    
    if let error = error {
      ac = UIAlertController(title: "Failed in Saving", message: error.localizedDescription, preferredStyle: .alert)
    } else {
      ac = UIAlertController(title: "Saving successful", message: "Your altered image has been saved to your photo album", preferredStyle: .alert)
    }
    
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    
  }
  
  @IBAction func intensityChanged(_ sender: UISlider) {
    processImage()
  }
  
  
  @IBAction func changeFilter(_ sender: UIButton) {
    // Change the filter to be applied to image
    
    let ac = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: chooseFilter))
    ac.addAction(UIAlertAction(title: "CIVignetteEffect", style: .default, handler: chooseFilter))   // InputCenter, InputIntensity, InputRadius
    ac.addAction(UIAlertAction(title: "CIPhotoEffectInstant", style: .default, handler: chooseFilter))
    ac.addAction(UIAlertAction(title: "CIPhotoEffectProcess", style: .default, handler: chooseFilter))
    ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: chooseFilter)) // InputAngle, InputRadius
    ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: chooseFilter))  // InputCenter, InputRadius, InputScale
    ac.addAction(UIAlertAction(title: "CICircleSplashDistortion", style: .default, handler: chooseFilter)) // InputCenter, InputRadius,
    ac.addAction(UIAlertAction(title: "CIBloom", style: .default, handler: chooseFilter)) // InputRadius, InputIntensity
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    present(ac, animated: true, completion: nil)
    
  }

  @IBAction func save(_ sender: UIButton) {
    // Save the image to photo library
    UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  

}

