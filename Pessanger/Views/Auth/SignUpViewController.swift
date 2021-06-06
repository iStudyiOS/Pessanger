//
//  SignUpViewController.swift
//  Pessanger
//
//  Created by bart Shin on 20/05/2021.
//

import UIKit

class SignUpViewController: UIViewController {
	
	private let authController: AuthController
	
	private let emailInput: UITextField
	private let passwordInputs: (UITextField, UITextField)
	private let nicknameInput: UITextField
	private var allInputs: [UITextField] {
		[ emailInput, passwordInputs.0, passwordInputs.1, nicknameInput]
	}
	private let signUpButton: UIButton
	private let backButton: UIButton
	private let backgroundView: UIView
	
	// MARK:- UI Adjust
	
	private let inputHeight: CGFloat = 50
	private let inputInterval: CGFloat = 30
	private let buttonBottomMargin: CGFloat = 50
	private var primaryColor: UIColor = .black
	private var secondaryColor: UIColor = .gray
	private var backgroundColor: UIColor = .white
	
	// MARK:- User Intents
	
	@objc private func tapBackground() {
		allInputs.forEach {
			$0.resignFirstResponder()
		}
	}
	
	@objc private func tapBackButton() {
		navigationController?.popViewController(animated: true)
	}
	
	@objc private func tapSignUpButton() {
		
		if validateFields() {
			authController.createUser(credential: AuthController.Credential(
																	email: emailInput.text!,
																	password: passwordInputs.0.text!),
																nickname: nicknameInput.text!) { myInfo in
				self.goToHomeView(myInfo: myInfo)
			}errorHandler: { error in
				_ = self.showAlert(for: error.localizedDescription)
			}
		}
	}
	
	private func goToHomeView(myInfo: UserInfo) {
		guard let user = authController.getCurrentUser() else {
<<<<<<< HEAD
			_ = showAlert(for: "Fail to go home, Error to get user infomation")
			return
		}
		let userController = NetworkController(db: authController.dbController, user: user, info: myInfo)
=======
			_ = showAlert(for: "사용자 정보 가져오기 실패, 재확인 필요")
			return
		}
		let userController = UserController(db: authController.dbController, user: user, info: myInfo)
>>>>>>> main
		let homeVC = HomeViewController(user: userController)
		let nav = UINavigationController(rootViewController: homeVC)
		nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
		nav.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isHidden = false
		view.window?.rootViewController = nav
		view.window?.makeKeyAndVisible()
	}
	
	private func validateFields() -> Bool {
<<<<<<< HEAD
		
		if passwordInputs.0.text != passwordInputs.1.text {
			return showAlert(for: "Password fields are different")
=======
        
		
		if passwordInputs.0.text != passwordInputs.1.text {
			return showAlert(for: "비밀번호가 서로 다릅니다.")
>>>>>>> main
		}
		
		guard let email = emailInput.text,
					let password = passwordInputs.0.text,
					nicknameInput.text != nil,
					allInputs.filter({ $0.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).isEmpty // find empty text field
		else {
<<<<<<< HEAD
			return showAlert(for: "Please fill all text fields")
		}
		
		if !authController.isValidEmail(email) {
			return showAlert(for: "Email is not vaild")
		}
		if !authController.isValidPassword(password) {
			return showAlert(for: "Password is not valid")
=======
			return showAlert(for: "모든 항목을 작성하시기 바랍니다.")
		}
		
		if !authController.isValidEmail(email) {
			return showAlert(for: "사용 가능한 이메일이 아닙니다.")
		}
		if !authController.isValidPassword(password) {
			return showAlert(for: "비밀번호는 8자 이상, 1개 이상의 특수문자로 설정하시기 바랍니다.")
>>>>>>> main
		}
		return true
	}
	
	private func showAlert(for message: String) -> Bool {
		let alert = UIAlertController(
<<<<<<< HEAD
			title: "Fail to sign up",
			message: message,
			preferredStyle: .alert)
		alert.addAction(UIAlertAction(
											title: "Dismiss",
=======
			title: "회원가입 실패",
			message: message,
			preferredStyle: .alert)
		alert.addAction(UIAlertAction(
											title: "확인",
>>>>>>> main
											style: .default))
		present(alert, animated: true)
		return false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layoutUI()
	}
	
	private func layoutUI() {
		
		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let inputVStack = UIStackView(
			arrangedSubviews: allInputs)
		let buttonVStack = UIStackView(
			arrangedSubviews: [
				signUpButton,
				backButton
			])
		
		view.addSubview(inputVStack)
		view.addSubview(buttonVStack)
		
		inputVStack.axis = .vertical
		inputVStack.distribution = .equalCentering
		inputVStack.arrangedSubviews.forEach { input in
			input.snp.makeConstraints {
				$0.height.equalTo(inputHeight)
			}
		}
		
		inputVStack.snp.makeConstraints { make in
			make.width.equalTo(view.snp.width).multipliedBy(0.7)
			make.height.equalTo(CGFloat(allInputs.count)*inputHeight + CGFloat(allInputs.count - 1)*inputInterval)
			make.centerX.equalTo(view.snp.centerX)
			make.centerY.equalTo(view.snp.centerY).multipliedBy(0.7)
		}
		buttonVStack.axis = .vertical
		buttonVStack.snp.makeConstraints { make in
			make.width.equalTo(view.snp.width).multipliedBy(0.3)
			make.height.equalTo(view.snp.height).multipliedBy(0.2)
			make.centerX.equalTo(view.snp.centerX)
			make.bottom.equalTo(view.snp.bottom).offset(-buttonBottomMargin)
		}
		
	}
	
	init(authController: AuthController) {
		self.authController = authController
		emailInput = UITextField()
		passwordInputs = (UITextField(), UITextField())
		nicknameInput = UITextField()
		signUpButton = UIButton()
		backButton = UIButton()
		backgroundView = UIView()
		super.init(nibName: nil, bundle: nil)
		
		initInputs()
		initButtons()
		initBackground()
	}
	
	private func initInputs() {
		allInputs.forEach {
			$0.borderStyle = .roundedRect
			$0.autocorrectionType = .no
			$0.delegate = self
			$0.returnKeyType = .next
			$0.autocapitalizationType = .none
		}
		nicknameInput.returnKeyType = .join
<<<<<<< HEAD
		emailInput.placeholder = "Email"
		emailInput.keyboardType = .emailAddress
		passwordInputs.0.placeholder = "Password"
		passwordInputs.1.placeholder = "Password confirm"
		passwordInputs.0.isSecureTextEntry = true
		passwordInputs.1.isSecureTextEntry = true
		nicknameInput.placeholder = "Nick name"
	}
	
	private func initButtons() {
		signUpButton.setTitle("Sign up", for: .normal)
		backButton.setTitle("Go back", for: .normal)
=======
		emailInput.placeholder = "이메일"
		emailInput.keyboardType = .emailAddress
		passwordInputs.0.placeholder = "비밀번호"
		passwordInputs.1.placeholder = "비밀번호 확인"
		passwordInputs.0.isSecureTextEntry = true
		passwordInputs.1.isSecureTextEntry = true
		nicknameInput.placeholder = "닉네임"
	}
	
	private func initButtons() {
		signUpButton.setTitle("회원가입", for: .normal)
		backButton.setTitle("뒤로", for: .normal)
>>>>>>> main
		signUpButton.setTitleColor(primaryColor, for: .normal)
		backButton.setTitleColor(secondaryColor, for: .normal)
		signUpButton.addTarget(self,
													 action: #selector(tapSignUpButton),
													 for: .touchUpInside)
		backButton.addTarget(self,
												 action: #selector(tapBackButton),
												 for: .touchUpInside)
	}
	
	private func initBackground() {
		backgroundView.backgroundColor = backgroundColor
		backgroundView.addGestureRecognizer(
			UITapGestureRecognizer(target: self,
														 action: #selector(tapBackground)))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

extension SignUpViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == allInputs.last {
			tapSignUpButton()
			return textField.resignFirstResponder()
		}
		let index = allInputs.firstIndex(of: textField)!
		allInputs[index + 1].becomeFirstResponder()
		return true
	}
}
