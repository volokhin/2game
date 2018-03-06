import Foundation
import UIKit
import AVFoundation

internal class NameVC : UIViewController {

	private var currentNameIndex: Int = 0

	private lazy var player: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "smb_kick", withExtension: "wav") else { return nil }
//		try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//		try? AVAudioSession.sharedInstance().setActive(true)
		return try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

		//			if #available(iOS 11, *) {
		//				player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
		//			} else {
		//				// show sad face emoji
		//			}
	}()

	private var nameView: NameView {
		return self.view as! NameView
	}

	internal override func loadView() {
		super.loadView()
		self.view = Bundle.main.loadNibNamed("NameView", owner: self, options: nil)?.first as? UIView
	}

	internal override func viewDidLoad() {
		let gr = UITapGestureRecognizer(target: self, action: #selector(self.changeName))
		self.view.addGestureRecognizer(gr)
		self.nameView.button.addTarget(self, action: #selector(self.selectName), for: .touchUpInside)
		self.updateName()

		GameService.shared.namesDidChange = {
			[weak self] in
			self?.updateName()
		}
	}

	internal override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	private func updateName() {
		guard GameService.shared.names.count > 0 else {
			self.nameView.name.text = nil
			return
		}
		
		let name = GameService.shared.names[self.currentNameIndex]

		UIView.performWithoutAnimation {
			if name == "Светлана" {
				self.nameView.button.setTitle("Иосики, фрукты!", for: .normal)
			} else {
				self.nameView.button.setTitle("Да, я \(name)", for: .normal)
			}
			self.nameView.button.layoutIfNeeded()
		}

		self.nameView.name.text = name
		self.nameView.name.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
		UIView.animate(withDuration: 0.15) {
			self.nameView.name.transform = CGAffineTransform(scaleX: 1, y: 1)
		}
	}

	@objc private func changeName() {
		self.player?.play()
		self.currentNameIndex = self.currentNameIndex + 1
		if self.currentNameIndex >= GameService.shared.names.count {
			self.currentNameIndex = 0
		}
		self.updateName()
	}

	@objc private func selectName() {
		UserDefaults.standard.set(GameService.shared.names[self.currentNameIndex], forKey: "user_name")
		self.navigationController?.pushViewController(AvatarVC(), animated: true)
	}



}
