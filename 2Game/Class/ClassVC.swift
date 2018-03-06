import Foundation
import UIKit
import AVFoundation

internal class ClassVC : UIViewController {

	private var currentClassIndex: Int = 0

	private var classView: ClassView {
		return self.view as! ClassView
	}

	private lazy var updateClassPlayer: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "smb_kick", withExtension: "wav") else { return nil }
		return try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
	}()

	private lazy var selectClassPlayer: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "smb_powerup", withExtension: "wav") else { return nil }
		return try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
	}()

	internal override func loadView() {
		super.loadView()
		self.view = Bundle.main.loadNibNamed("ClassView", owner: self, options: nil)?.first as? UIView
	}

	internal override func viewDidLoad() {
		let name = UserDefaults.standard.object(forKey: "user_name") as? String
		let avatarIndex = UserDefaults.standard.object(forKey: "user_avatar") as? Int
		self.classView.name.text = name
		self.classView.avatar.image = GameService.shared.avatars[avatarIndex ?? 0]

		let gr = UITapGestureRecognizer(target: self, action: #selector(self.changeClass))
		self.view.addGestureRecognizer(gr)
		self.classView.button.addTarget(self, action: #selector(self.selectClass), for: .touchUpInside)
		self.updateClass()
	}

	internal override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	private func updateClass() {
		let power = GameService.shared.classes[self.currentClassIndex]

		self.classView.className.text = power.name
		self.classView.classDescription.text = power.description

		self.classView.className.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
		UIView.animate(withDuration: 0.15) {
			self.classView.className.transform = CGAffineTransform(scaleX: 1, y: 1)
		}
	}

	@objc private func changeClass() {
		self.updateClassPlayer?.play()
		self.currentClassIndex = self.currentClassIndex + 1
		if self.currentClassIndex >= GameService.shared.classes.count {
			self.currentClassIndex = 0
		}
		self.updateClass()
	}

	@objc private func selectClass() {

		self.selectClassPlayer?.play()
		UserDefaults.standard.set(self.currentClassIndex, forKey: "user_class")
		self.navigationController?.pushViewController(UserVC(), animated: true)
	}

}
