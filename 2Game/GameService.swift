import Foundation
import UIKit
import GameKit

internal struct UserClass {
	internal let name: String
	internal let description: String
}

internal struct UserSkill {
	internal let name: String
	internal let value: Int
}

internal struct UserPower {
	internal let name: String
	internal let description: String
}

internal struct UserLevel {
	internal let level: Int
	internal let start: Int
	internal let stop: Int = 1000
	internal var progress: Double {
		return Double(self.start) / 1000.0
	}
}

internal struct ApiResult : Decodable {

	internal let response: [User]

	enum CodingKeys: String, CodingKey {
		case response = "response"
	}
}

internal struct User : Decodable {
	internal let name: String
	internal let exp: Int

	enum CodingKeys: String, CodingKey {
		case name = "name"
		case exp = "score"
	}
}

internal class RandomService {

	private let rs: GKMersenneTwisterRandomSource
	private let rd: GKRandomDistribution

	internal init(seed: Int) {
		let rs = GKMersenneTwisterRandomSource()
		rs.seed = UInt64(seed)
		self.rs = rs
		self.rd = GKRandomDistribution(randomSource: rs, lowestValue: 1, highestValue: 5)
	}

	internal func nextInt() -> Int {
		return self.rd.nextInt()
	}
}

internal class GameService {

	internal static let shared = GameService()

	private var timer: Timer!

	internal var expDidChange: (() -> Void)?
	internal var levelDidChange: (() -> Void)?
	internal var namesDidChange: (() -> Void)?

	private var seed: Int = 0 {
		didSet {
			UserDefaults.standard.set(self.seed, forKey: "user_seed")
		}
	}

	internal var exp: Int = 0 {
		didSet {
			UserDefaults.standard.set(self.exp, forKey: "user_exp")
			self.expDidChange?()
			self.levelValue = self.level().level
		}
	}

	internal var levelValue: Int = 0 {
		didSet {
			if oldValue < self.levelValue {
				self.levelDidChange?()
			}
		}
	}

	internal let avatars = [
		#imageLiteral(resourceName: "avatar1"), #imageLiteral(resourceName: "avatar2"), #imageLiteral(resourceName: "avatar3"), #imageLiteral(resourceName: "avatar4"), #imageLiteral(resourceName: "avatar5"), #imageLiteral(resourceName: "avatar6"), #imageLiteral(resourceName: "avatar7"), #imageLiteral(resourceName: "avatar8"), #imageLiteral(resourceName: "avatar9"), #imageLiteral(resourceName: "avatar10"), #imageLiteral(resourceName: "avatar11"), #imageLiteral(resourceName: "avatar12"), #imageLiteral(resourceName: "avatar13"), #imageLiteral(resourceName: "avatar14"), #imageLiteral(resourceName: "avatar15"), #imageLiteral(resourceName: "avatar16")
	]

	internal var names: [String] = []

	internal let classes = [
		UserClass(name: "Сеньор ведущий специалист", description: "Очень опытный и высокооплачиваемый игрок, не первый год в теме. Все заработанные им деньги удваиваются."),
		UserClass(name: "Энтузиаст с горящими глазами", description: "Смотрит на этот мир наивным взглядом новичка, полными восхищения. Зато очень быстро учится – весь полученный опыт удваивается."),
		UserClass(name: "Любимая внучка бармена", description: "Мастерски использует родственные связи с хозяином бара для личной выгоды. Любой напиток может один раз повторить бесплатно."),
		UserClass(name: "Лучший ученик бармена", description: "В свои молодые годы уже очень многому научилась у хозяина бара. Может получать коктейли на один уровень выше своих текущих навыков."),
		UserClass(name: "Дитя удачи", description: "Доподлинно неизвестно как она это делает, но в случае проигрыша всегда получает столько денег и опыта, как если бы выиграла по-честному."),
	]

	internal init() {
		let seed = UserDefaults.standard.object(forKey: "user_seed") as? Int
		let exp = UserDefaults.standard.object(forKey: "user_exp") as? Int
		self.seed = seed ?? Int(arc4random_uniform(100))
		self.exp = exp ?? 0
		self.levelValue = self.level().level
		UserDefaults.standard.set(self.seed, forKey: "user_seed")
		UserDefaults.standard.set(self.exp, forKey: "user_exp")

		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.fetchData),
											   name: .UIApplicationDidBecomeActive,
											   object: nil)
	}

	internal func skills() -> [UserSkill] {

		let name = UserDefaults.standard.object(forKey: "user_name") as? String ?? ""
		let round = RandomService(seed: seed)
		let level = self.level().level

		var values: [Int] = []
		for _ in 0...5 {
			var value = 0
			for _ in 0...level {
				value = value + round.nextInt()
			}
			values.append(value)
		}

		values[4] = values[4] * 10

		let s1 = UserSkill(name: "Нацеленность на позитив", value: values[0])
		let s2 = UserSkill(name: "Ориентация на отдых", value: values[1])
		let s3 = UserSkill(name: "Готовность к развлечениям", value: values[2])
		let s4 = UserSkill(name: "Безудержность веселья", value: values[3])
		let s5: UserSkill

		switch name {
		case "Анжела":
			s5 = UserSkill(name: "Талант инстаграмера", value: values[4])
		case "Даша":
			s5 = UserSkill(name: "Ёпта-дерёпта!", value: values[4])
		case "Лида":
			s5 = UserSkill(name: "Тяга к приключениями", value: values[4])
		case "Маша Е.":
			s5 = UserSkill(name: "Умножение радости", value: values[4])
		case "Маша П.":
			s5 = UserSkill(name: "Любовь к команде", value: values[4])
		case "Маша Я.":
			s5 = UserSkill(name: "Скромность", value: values[4])
		case "Настя":
			s5 = UserSkill(name: "Охота за головами", value: values[4])
		case "Наташа":
			s5 = UserSkill(name: "Эскалация релаксации", value: values[4])
		case "Оксана":
			s5 = UserSkill(name: "Компетентность", value: values[4])
		case "Оля":
			s5 = UserSkill(name: "Несгибаемый оптимизм", value: values[4])
		case "Роза":
			s5 = UserSkill(name: "Баг, драг и рок-н-ролл", value: values[4])
		case "Саша":
			s5 = UserSkill(name: "Практическая толкиенистка", value: values[4])
		case "Света А.":
			s5 = UserSkill(name: "Умение выходить из VIM'a", value: values[4])
		case "Света Ш.":
			s5 = UserSkill(name: "Настойчивость", value: values[4])
		case "Светлана":
			s5 = UserSkill(name: "Забота", value: values[4])
		case "Юля Г.":
			s5 = UserSkill(name: "Осознанность", value: values[4])
		case "Юля Ю.":
			s5 = UserSkill(name: "Любознательность", value: values[4])
		default:
			s5 = UserSkill(name: "Эскалация релаксации", value: values[4])
		}
		return [s1, s2, s3, s4, s5]
	}

	internal func powers() -> [UserPower] {

		let name = UserDefaults.standard.object(forKey: "user_name") as? String ?? ""

		if name == "Светлана" {
			return [UserPower(name: "Хозяйка офиса", description: "Светлане можно всё")]
		}

		let level = self.level().level
		switch level {
		case 0...1:
			return [UserPower(name: "Навеселе", description: "Возможность получить в баре коктейль 1 уровня")]
		case 2:
			return [UserPower(name: "Подшофе", description: "Возможность получить в баре коктейль 2 уровня")]
		case 3:
			return [UserPower(name: "Поддатый", description: "Возможность получить в баре коктейль 3 уровня")]
		case 4:
			return [UserPower(name: "Напилася я пьяну", description: "Возможность получить в баре коктейль 4 уровня")]
		case 5:
			return [UserPower(name: "В стельку", description: "Возможность получить в баре коктейль 5 уровня, безлимитный доступ к бару"),
					UserPower(name: "Закусон", description: "Возможность получить в баре вкусное угощение")]
		default:
			return [UserPower(name: "В стельку", description: "Возможность получить в баре коктейль 5 уровня, безлимитный доступ к бару"),
					UserPower(name: "Закусон", description: "Возможность получить в баре вкусное угощение")]
		}
	}

	internal func level() -> UserLevel {
		let name = UserDefaults.standard.object(forKey: "user_name") as? String ?? ""

		if name == "Светлана" {
			return UserLevel(level: 99, start: Int(1000))
		}

		let level = (Double(self.exp) / 1000.0).rounded(.down)
		let exp = Double(self.exp) - Double(level) * 1000.0
		return UserLevel(level: Int(level) + 1, start: Int(exp))
	}

	internal func start() {
		self.timer = Timer.scheduledTimer(
			timeInterval: 10,
			target: self,
			selector: #selector(self.fetchData),
			userInfo: nil,
			repeats: true)
		self.timer.fire()
	}

	@objc internal func fetchData() {
		let url = URL(string: "http://rnazarov.ru/2gis/girls")!
		let request = URLRequest(url: url)
		let task = URLSession.shared.dataTask(with: request as URLRequest) {
			[weak self] (data: Data?, urlResponse: URLResponse?, error: Error?) in

			guard let data = data else { return }
			guard let this = self else { return }
			DispatchQueue.main.async {
				this.updateData(with: data)
			}
		}

		task.resume()
	}

	private func updateData(with data: Data) {
		let decoder = JSONDecoder()
		let results = try? decoder.decode(ApiResult.self, from: data)
		if let results = results {
			self.updateData(with: results.response)
		}
	}

	private func updateData(with users: [User]) {
		self.names = users.map { $0.name }
		self.namesDidChange?()
		let name = UserDefaults.standard.object(forKey: "user_name") as? String ?? ""
		let currentUser = users.first { $0.name == name }
		if let currentUser = currentUser {
			self.exp = currentUser.exp
		}
	}
}
