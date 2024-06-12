//
//  StoryPlayViewController.swift
//  Task_12
//
//  Created by DREAMWORLD on 25/05/24.
//

import UIKit
import AVFoundation
import SDWebImage

class StoryPlayViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var playerView: UIView!
    
    var content = [Content]()
    var user: UserDetails! {
        didSet {
            content = user.content
        }
    }
    var progresses = [UISlider]()
    var storyCnt = 0
    var index: Int!
    
    var storyTimer: Timer!
    var totalTime = 5.0
    var elapsedTime = 0.0
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoStory = false
    
    var delegate: ScrollUserStory?
    
    var isNextStory: Bool!
    var isPrevStroy: Bool!
    private var preloadedNextImage: UIImage?
    private var preloadedNextPlayerItem: AVPlayerItem?
    private var preloadedPrevImage: UIImage?
    private var preloadedPrevPlayerItem: AVPlayerItem?
    
    // Add a loader
    @IBOutlet weak var loader: UIActivityIndicatorView!
    private var timeControlStatusObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        view.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            player?.pause()
            storyTimer.invalidate()
        } else {
            player?.play()
            storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isNextStory = false
        isPrevStroy = false
        
        setUserData()
        setSliders()
    }
    
    func setUserData() {
        userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
        userProfileImage.sd_setImage(with: URL(string: user.imageUrl)!, placeholderImage: UIImage(named: "person"))
        userName.text = user.name
    }
    
    func setSliders() {
        
        storyCnt = 0
        
        progressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progresses.removeAll()
        
        for _ in 0...content.count - 1 {

            let slider = UISlider()
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.setThumbImage(UIImage(), for: .normal)
            
            slider.setMinimumTrackImage(createTrackImage(color: .red, size: CGSize(width: 300, height: 5)), for: .normal)
            slider.setMaximumTrackImage(createTrackImage(color: .red.withAlphaComponent(0.5), size: CGSize(width: 300, height: 5)), for: .normal)
            
            self.progresses.append(slider)
            self.progressStackView.addArrangedSubview(slider)
        }
        
        showStory()
    }
    
    func createTrackImage(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func showStory() {
        storyTimer?.invalidate()
        if content[storyCnt].type == "video" {
            showVideoStory()
        } else {
            showImageStory()
        }
    }
    
    func showVideoStory() {
        isVideoStory = true
        playerView.isHidden = false
        storyImage.isHidden = true
        
        guard let url = URL(string: content[storyCnt].url) else { return }
        
        // Check if the video is cached
        if let cachedItem = loadCachedPlayerItem(for: url) {
            player = AVPlayer(playerItem: cachedItem)
            print("cashed video")
        } else {
            let preloadedItem: AVPlayerItem?
            if isNextStory {
                preloadedItem = preloadedNextPlayerItem
            } else if isPrevStroy {
                preloadedItem = preloadedPrevPlayerItem
            } else {
                preloadedItem = nil
            }
            
            if let preloadedItem = preloadedItem, preloadedItem.asset.isPlayable {
                player = AVPlayer(playerItem: preloadedItem)
                print("preloaded video")
            } else {
                player = AVPlayer(url: url)
            }
            
            // Cache the player item
            cachePlayerItem(url: url)
        }
        
        isPrevStroy = false
        isNextStory = false
        
        //player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.frame
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerView.layer.addSublayer(playerLayer)
        
        loader.isHidden = false
        view.bringSubviewToFront(loader)
        
        totalTime = CMTimeGetSeconds(AVAsset(url: url).duration)
        elapsedTime = 0.1
        
        timeControlStatusObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            if player.timeControlStatus == .playing {
                self?.loader.isHidden = true
            }
        }
        
        player.play()
        
        storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        preloadAdjacentContent()
    }
    
    private func loadCachedPlayerItem(for url: URL) -> AVPlayerItem? {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cachedURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: cachedURL.path) {
            return AVPlayerItem(url: cachedURL)
        } else {
            return nil
        }
    }

    private func cachePlayerItem(url: URL) {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cachedURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                try data.write(to: cachedURL)
                print("Video cached at: \(cachedURL.path)")
            } catch {
                print("Error caching player item:", error)
            }
        }.resume()
    }
    
    func showImageStory() {
        isVideoStory = false
        playerView.isHidden = true
        storyImage.isHidden = false
        
        totalTime = 5.0
        elapsedTime = 0.1
        
        guard let url = URL(string: content[storyCnt].url) else { return }
        
//        storyImage.sd_setImage(with: url) { _, _, _, _ in
//            self.storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
//        }
        
        if let preloadedImage = preloadedNextImage, storyCnt == content.count - 1 {
            storyImage.image = preloadedImage
            self.storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        } else if let preloadedImage = preloadedPrevImage, storyCnt > 0 {
            storyImage.image = preloadedImage
            self.storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        } else {
            storyImage.sd_setImage(with: url) {  _, _, _, _ in
                self.storyTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
            }
        }

        isPrevStroy = false
        isNextStory = false
        
        preloadAdjacentContent()
    }
    
    func preloadAdjacentContent() {
        let nextIndex = storyCnt + 1
        if nextIndex < content.count {
            let nextContent = content[nextIndex]
            if nextContent.type == "image", let url = URL(string: nextContent.url) {
                SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { [weak self] image, _, _, _, _, _ in
                    self?.preloadedNextImage = image
                }
            } else if nextContent.type == "video", let url = URL(string: nextContent.url) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerItem.preferredForwardBufferDuration = 10.0
                preloadedNextPlayerItem = playerItem
            }
        }

        let prevIndex = storyCnt - 1
        if prevIndex >= 0 {
            let prevContent = content[prevIndex]
            if prevContent.type == "image", let url = URL(string: prevContent.url) {
                SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { [weak self] image, _, _, _, _, _ in
                    self?.preloadedPrevImage = image
                }
            } else if prevContent.type == "video", let url = URL(string: prevContent.url) {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerItem.preferredForwardBufferDuration = 10.0
                preloadedPrevPlayerItem = playerItem
            }
        }
    }
    
    deinit {
        timeControlStatusObserver?.invalidate()
        player?.pause()
    }
    
    @objc func updateProgress() {
        
        if isVideoStory {
            elapsedTime = CMTimeGetSeconds(player.currentTime())
        } else {
            self.elapsedTime += 0.1
        }
        
        self.progresses[self.storyCnt].setValue(Float(self.elapsedTime / self.totalTime), animated: true)
        
        if elapsedTime >= self.totalTime {
            storyTimer.invalidate()
            progresses[storyCnt].value = 1
            changeStory()
        }
        
    }
    
    @objc func changeStory() {
        
        player?.pause()
        player = nil
        
        if storyCnt < content.count - 1 {
            storyCnt += 1
            isNextStory = true
            showStory()
        } else {
            self.delegate?.scrollToNextUser()
        }
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        player?.pause()
        let location = sender.location(in: view)
        if location.x < view.bounds.width / 2 {
            if storyCnt > 0 {
                progresses[storyCnt].value = 0
                storyCnt -= 1
                isPrevStroy = true
                self.showStory()
            } else {
                self.delegate?.scrollToPreviousUser()
            }
            
        } else {
            if storyCnt < content.count - 1 {
                progresses[storyCnt].value = 1
                storyCnt += 1
                isNextStory = true
                self.showStory()
            } else {
                self.delegate?.scrollToNextUser()
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        storyTimer?.invalidate()
        player?.pause()
    }

    @IBAction func cancleButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
