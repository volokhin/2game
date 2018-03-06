import Foundation
import UIKit
import AVFoundation

internal class AvatarVC : UIViewController {

	private var currentAvatarIndex: Int = 0

	private lazy var player: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "smb_kick", withExtension: "wav") else { return nil }
		return try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
	}()

	private var avatarView: AvatarView {
		return self.view as! AvatarView
	}

	internal override func loadView() {
		super.loadView()
		self.view = Bundle.main.loadNibNamed("AvatarView", owner: self, options: nil)?.first as? UIView
	}

	internal override func viewDidLoad() {
		let name = UserDefaults.standard.object(forKey: "user_name") as? String
		self.avatarView.name.text = name
		let gr = UITapGestureRecognizer(target: self, action: #selector(self.changeAvatar))
		self.view.addGestureRecognizer(gr)
		self.avatarView.button.addTarget(self, action: #selector(self.selectAvatar), for: .touchUpInside)
		self.updateAvatar()
	}

	internal override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	private func updateAvatar() {
		let avatar = GameService.shared.avatars[self.currentAvatarIndex]

		self.avatarView.avatar.image = avatar
		self.avatarView.avatar.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
		UIView.animate(withDuration: 0.15) {
			self.avatarView.avatar.transform = CGAffineTransform(scaleX: 1, y: 1)
		}
	}

	@objc private func changeAvatar() {
		self.player?.play()
		self.currentAvatarIndex = self.currentAvatarIndex + 1
		if self.currentAvatarIndex >= GameService.shared.avatars.count {
			self.currentAvatarIndex = 0
		}
		self.updateAvatar()
	}

	@objc private func selectAvatar() {
		UserDefaults.standard.set(self.currentAvatarIndex, forKey: "user_avatar")
		self.navigationController?.pushViewController(ClassVC(), animated: true)
	}



}
