import Foundation
import UIKit
import AVFoundation

internal class UserVC : UIViewController {

	private var userView: UserView {
		return self.view as! UserView
	}

	private lazy var player: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "smb_powerup", withExtension: "wav") else { return nil }
		return try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
	}()

	internal override func loadView() {
		super.loadView()
		self.view = Bundle.main.loadNibNamed("UserView", owner: self, options: nil)?.first as? UIView
	}

	internal override func viewDidLoad() {
		let name = UserDefaults.standard.object(forKey: "user_name") as? String
		let avatarIndex = UserDefaults.standard.object(forKey: "user_avatar") as? Int
		let classIndex = UserDefaults.standard.object(forKey: "user_class") as? Int
		let userClass = GameService.shared.classes[classIndex ?? 0]

		self.userView.name.text = name
		self.userView.avatar.image = GameService.shared.avatars[avatarIndex ?? 0]
		self.userView.className.text = userClass.name
		self.userView.superpower.text = userClass.description

		self.update()

		GameService.shared.expDidChange = {
			[weak self] in
			self?.update()
		}

		GameService.shared.levelDidChange = {
			[weak self] in
			self?.notifyNewLevel()
		}

		GameService.shared.fetchData()
	}

	internal override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	private func update() {

		let level = GameService.shared.level()

		self.userView.level.text = "\(level.level)"
		self.userView.progress.progress = Float(level.progress)
		self.userView.progressDescription.text = "\(level.start)/\(level.stop)"

		for view in self.userView.skillsStackView.arrangedSubviews {
			self.userView.skillsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		for view in self.userView.powersStackView.arrangedSubviews {
			self.userView.powersStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		let skills = GameService.shared.skills()
		for skill in skills {
			if let skillView = Bundle.main.loadNibNamed("SkillView", owner: self, options: nil)?.first as? SkillView {
				skillView.skillDescription.text = skill.name
				skillView.skillValue.text = "\(skill.value)"
				self.userView.skillsStackView.addArrangedSubview(skillView)
			}
		}

		let powers = GameService.shared.powers()
		for power in powers {
			if let powerView = Bundle.main.loadNibNamed("PowerView", owner: self, options: nil)?.first as? PowerView {
				powerView.powerName.text = power.name
				powerView.powerDescription.text = power.description
				self.userView.powersStackView.addArrangedSubview(powerView)
			}
		}

		self.view.setNeedsLayout()

	}

	private func notifyNewLevel() {
		self.player?.play()
		let alert = UIAlertController(title: "Новый уровень!",
								  message: "Поздравляю! Ты достигла \(GameService.shared.levelValue) уровня :)",
								  preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Еее!", style: .cancel)
		alert.addAction(cancel)
		self.present(alert, animated: true, completion: nil)
	}
}
