import Foundation
import UIKit

internal class UserView : UIView {
	@IBOutlet internal weak var avatar: UIImageView!
	@IBOutlet internal weak var name: UILabel!
	@IBOutlet internal weak var className: UILabel!
	@IBOutlet internal weak var level: UILabel!
	@IBOutlet internal weak var progress: UIProgressView!
	@IBOutlet internal weak var progressDescription: UILabel!
	@IBOutlet internal weak var superpower: UILabel!
	@IBOutlet internal weak var skillsStackView: UIStackView!
	@IBOutlet internal weak var powersStackView: UIStackView!
}
