//
//  SignInViewConroller.swift
//  Pessanger
//
//  Created by bart Shin on 20/05/2021.
//

import UIKit
import SnapKit

class SignInViewConroller: UIViewController {
<<<<<<< HEAD
	
	private let authController: AuthController
	
	private let emailInput: UITextField
	private let passwordInput: UITextField
	private let signInButton: UIButton
	private let signUpButton: UIButton
	private let saveCredentialButton: UIButton
	private let autoSignInButton: UIButton
	private let backgroundView: UIView
	
	// MARK:- UI Adjust
	
	private let inputHeight: CGFloat = 50
	private let inputInterval: CGFloat = 30
	private let toggleButtonHeight: CGFloat = 30
	private let buttonBottomMargin: CGFloat = 50
	private var primaryColor: UIColor = .black
	private var secondaryColor: UIColor = .gray
	private var backgroundColor: UIColor = .white
	
	// MARK:- User Intents
	
	@objc private func tapSignIn() {
		guard let email = emailInput.text,
					let password = passwordInput.text,
					!email.isEmpty,
					!email.isEmpty else {
			showAlert(for: "Please fill email and password")
			return
		}
		authController.signIn(credential:
														AuthController.Credential(
															email: email, password: password)) { myInfo in
			self.goToHomeView(myInfo: myInfo)
		} errorHandler: { error in
			self.showAlert(for: error.localizedDescription)
		}
	}
	
	private func goToHomeView(myInfo: UserInfo) {
		guard let user = authController.getCurrentUser() else {
			showAlert(for: "Fail to go home, Error to get user infomation")
			return
		}
		let userController = NetworkController(db: authController.dbController, user: user, info: myInfo)
		let homeVC = HomeViewController(user: userController)
		let nav = UINavigationController(rootViewController: homeVC)
		nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
		nav.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isHidden = false
		view.window?.rootViewController = nav
		view.window?.makeKeyAndVisible()
	}
	
	@objc private func tapSignUp() {
		let signUpVC = SignUpViewController(authController: authController)
		navigationController?.pushViewController(signUpVC, animated: true)
	}
	
	@objc private func tapToggleButton(_ sender: UIButton) {
		sender.isSelected.toggle()
		if sender == saveCredentialButton {
			authController.changeAutoSaveCredential(to: sender.isSelected)
		}else if sender == autoSignInButton {
			authController.changeAutoSignIn(to: sender.isSelected)
		}
	}
	
	@objc private func tapBackground() {
		emailInput.resignFirstResponder()
		passwordInput.resignFirstResponder()
	}
	
	private func showAlert(for message: String) {
		let alert = UIAlertController(
			title: "Fail to sign In",
			message: message,
			preferredStyle: .alert)
		alert.addAction(UIAlertAction(
											title: "Dismiss",
											style: .default))
		present(alert, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layoutUI()
		if authController.savingCredential {
			fillCredential()
		}
	}
	
	private func fillCredential() {
		guard let credential = authController.retrieveSavedCredential() else {
			return
		}
		emailInput.text = credential.email
		passwordInput.text = credential.password
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
	}
	
	private func layoutUI() {
	
		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let topVStack = UIStackView(
			arrangedSubviews: [
				emailInput,
				passwordInput,
				saveCredentialButton,
				autoSignInButton
			])
		let bottomVStack = UIStackView(
			arrangedSubviews: [
				signInButton,
				signUpButton
			])
		
		view.addSubview(topVStack)
		view.addSubview(bottomVStack)
		
		topVStack.axis = .vertical
		topVStack.distribution = .equalSpacing
		topVStack.arrangedSubviews.forEach { subview in
			if subview is UIButton{
				subview.snp.makeConstraints {
					$0.height.equalTo(toggleButtonHeight)
				}
			}else {
				subview.snp.makeConstraints {
					$0.height.equalTo(inputHeight)
				}
			}
		}
		
		topVStack.snp.makeConstraints { make in
			make.width.equalTo(view.snp.width).multipliedBy(0.7)
			make.height.equalTo(2*inputHeight + 2*inputInterval + 2*toggleButtonHeight)
			make.centerX.equalTo(view.snp.centerX)
			make.centerY.equalTo(view.snp.centerY).multipliedBy(0.7)
		}
		bottomVStack.axis = .vertical
		bottomVStack.snp.makeConstraints { make in
			make.width.equalTo(view.snp.width).multipliedBy(0.3)
			make.height.equalTo(view.snp.height).multipliedBy(0.2)
			make.centerX.equalTo(view.snp.centerX)
			make.bottom.equalTo(view.snp.bottom).offset(-buttonBottomMargin)
		}
		
	}
	
	init(authController: AuthController) {
		
		self.authController = authController
		emailInput = UITextField()
		passwordInput = UITextField()
		signInButton = UIButton()
		signUpButton = UIButton()
		saveCredentialButton = UIButton()
		autoSignInButton = UIButton()
		backgroundView = UIView()
		super.init(nibName: nil, bundle: nil)
		
		initInputs()
		initButtons()
		initBackground()
	}
	
	private func initInputs() {
		emailInput.placeholder = "Email"
		emailInput.keyboardType = .emailAddress
		emailInput.autocorrectionType = .no
		emailInput.returnKeyType = .next
		emailInput.borderStyle = .roundedRect
		emailInput.autocapitalizationType = .none
		emailInput.delegate = self
		passwordInput.placeholder = "Password"
		passwordInput.isSecureTextEntry = true
		passwordInput.borderStyle = .roundedRect
		passwordInput.autocapitalizationType = .none
		passwordInput.delegate = self
	}
	
	private func initButtons() {
		signInButton.setTitle("Sign in", for: .normal)
		signUpButton.setTitle("Sign up", for: .normal)
		saveCredentialButton.setTitle("Save email & password", for: .normal)
		saveCredentialButton.setTitle("Don't save email & password", for: .selected)
		autoSignInButton.setTitle("Use auto sign in", for: .normal)
		autoSignInButton.setTitle("Don't use auto sign in", for: .selected)
		saveCredentialButton.isSelected = authController.savingCredential
		autoSignInButton.isSelected = authController.autoSignIn
		signInButton.setTitleColor(primaryColor, for: .normal)
		signUpButton.setTitleColor(secondaryColor, for: .normal)
		saveCredentialButton.setTitleColor(primaryColor, for: .normal)
		saveCredentialButton.setTitleColor(secondaryColor, for: .selected)
		autoSignInButton.setTitleColor(primaryColor, for: .normal)
		autoSignInButton.setTitleColor(secondaryColor, for: .selected)
		signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)
		signUpButton.addTarget(self, action: #selector(tapSignUp), for: .touchUpInside)
		saveCredentialButton.addTarget(self, action: #selector(tapToggleButton(_:)), for: .touchUpInside)
		autoSignInButton.addTarget(self, action: #selector(tapToggleButton(_:)), for: .touchUpInside)
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

extension SignInViewConroller: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailInput {
			passwordInput.becomeFirstResponder()
		}else if textField == passwordInput {
			textField.resignFirstResponder()
			tapSignIn()
		}
		return true
	}
=======
    
    private let authController: AuthController
    
    private let emailInput: UITextField
    private let passwordInput: UITextField
    private let signInButton: UIButton
    private let signUpButton: UIButton
    private let saveCredentialButton: UIButton
    private let autoSignInButton: UIButton
    private let backgroundView: UIView
    
    // MARK:- UI Adjust
    
    private let inputHeight: CGFloat = 50
    private let inputInterval: CGFloat = 30
    private let toggleButtonHeight: CGFloat = 30
    private let buttonBottomMargin: CGFloat = 50
    private var primaryColor: UIColor = .black
    private var secondaryColor: UIColor = .gray
    private var backgroundColor: UIColor = .white
    
    // MARK:- User Intents
    
    @objc private func tapSignIn() {
        guard let email = emailInput.text,
              let password = passwordInput.text,
              !email.isEmpty,
              !email.isEmpty else {
            showAlert(for: "이메일과 비밀번호를 작성해주세요")
            return
        }
        authController.signIn(credential:AuthController.Credential(
                                email: email,
                                password: password)) { myInfo in
            self.goToHomeView(myInfo: myInfo)
        } errorHandler: { error in
            self.showAlert(for: error.localizedDescription)
        }
    }
    
    private func goToHomeView(myInfo: UserInfo) {
        guard let user = authController.getCurrentUser() else {
            showAlert(for: "사용자 정보 가져오기 실패, 재확인 필요")
            return
        }
        let userController = UserController(db: authController.dbController, user: user, info: myInfo)
        let homeVC = HomeViewController(user: userController)
        let nav = UINavigationController(rootViewController: homeVC)
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isHidden = false
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
    @objc private func tapSignUp() {
        let signUpVC = SignUpViewController(authController: authController)
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func tapToggleButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender == saveCredentialButton {
            authController.changeAutoSaveCredential(to: sender.isSelected)
        }else if sender == autoSignInButton {
            authController.changeAutoSignIn(to: sender.isSelected)
        }
    }
    
    @objc private func tapBackground() {
        emailInput.resignFirstResponder()
        passwordInput.resignFirstResponder()
    }
    
    private func showAlert(for message: String) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
                            title: "확인",
                            style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        if authController.savingCredential {
            fillCredential()
        }
    }
    
    private func fillCredential() {
        guard let credential = authController.retrieveSavedCredential() else {
            return
        }
        emailInput.text = credential.email
        passwordInput.text = credential.password
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func layoutUI() {
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let topVStack = UIStackView(
            arrangedSubviews: [
                emailInput,
                passwordInput,
                saveCredentialButton,
                autoSignInButton
            ])
        let bottomVStack = UIStackView(
            arrangedSubviews: [
                signInButton,
                signUpButton
            ])
        
        view.addSubview(topVStack)
        view.addSubview(bottomVStack)
        
        topVStack.axis = .vertical
        topVStack.distribution = .equalSpacing
        topVStack.arrangedSubviews.forEach { subview in
            if subview is UIButton{
                subview.snp.makeConstraints {
                    $0.height.equalTo(toggleButtonHeight)
                }
            }else {
                subview.snp.makeConstraints {
                    $0.height.equalTo(inputHeight)
                }
            }
        }
        
        topVStack.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
            make.height.equalTo(2*inputHeight + 2*inputInterval + 2*toggleButtonHeight)
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).multipliedBy(0.7)
        }
        bottomVStack.axis = .vertical
        bottomVStack.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.3)
            make.height.equalTo(view.snp.height).multipliedBy(0.2)
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-buttonBottomMargin)
        }
        
    }
    
    init(authController: AuthController) {
        
        self.authController = authController
        emailInput = UITextField()
        passwordInput = UITextField()
        signInButton = UIButton()
        signUpButton = UIButton()
        saveCredentialButton = UIButton()
        autoSignInButton = UIButton()
        backgroundView = UIView()
        super.init(nibName: nil, bundle: nil)
        
        initInputs()
        initButtons()
        initBackground()
    }
    
    private func initInputs() {
        emailInput.placeholder = "이메일"
        emailInput.keyboardType = .emailAddress
        emailInput.autocorrectionType = .no
        emailInput.returnKeyType = .next
        emailInput.borderStyle = .roundedRect
        emailInput.autocapitalizationType = .none
        emailInput.delegate = self
        passwordInput.placeholder = "비밀번호"
        passwordInput.isSecureTextEntry = true
        passwordInput.borderStyle = .roundedRect
        passwordInput.autocapitalizationType = .none
        passwordInput.delegate = self
    }
    
    private func initButtons() {
        signInButton.setTitle("로그인", for: .normal)
        signUpButton.setTitle("회원가입", for: .normal)
        saveCredentialButton.setTitle("이메일, 비밀번호 저장", for: .normal)
        saveCredentialButton.setTitle("이메일, 비밀번호 저장하지 않기", for: .selected)
        autoSignInButton.setTitle("자동 로그인 사용", for: .normal)
        autoSignInButton.setTitle("자동 로그인 사용하지 않기", for: .selected)
        saveCredentialButton.isSelected = authController.savingCredential
        autoSignInButton.isSelected = authController.autoSignIn
        signInButton.setTitleColor(primaryColor, for: .normal)
        signUpButton.setTitleColor(secondaryColor, for: .normal)
        saveCredentialButton.setTitleColor(primaryColor, for: .normal)
        saveCredentialButton.setTitleColor(secondaryColor, for: .selected)
        autoSignInButton.setTitleColor(primaryColor, for: .normal)
        autoSignInButton.setTitleColor(secondaryColor, for: .selected)
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(tapSignUp), for: .touchUpInside)
        saveCredentialButton.addTarget(self, action: #selector(tapToggleButton(_:)), for: .touchUpInside)
        autoSignInButton.addTarget(self, action: #selector(tapToggleButton(_:)), for: .touchUpInside)
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

extension SignInViewConroller: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailInput {
            passwordInput.becomeFirstResponder()
        }else if textField == passwordInput {
            textField.resignFirstResponder()
            tapSignIn()
        }
        return true
    }
>>>>>>> main
}
