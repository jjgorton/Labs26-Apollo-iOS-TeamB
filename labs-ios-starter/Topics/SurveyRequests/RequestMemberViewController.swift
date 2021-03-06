//
//  RequestMemberViewController.swift
//  labs-ios-starter
//
//  Created by Hunter Oppel on 10/12/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

protocol SurveyRequestDelegate {
    func didGetSurveyRequest(_ request: Survey)
}

class RequestMemberViewController: ShiftableViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var addNewQuestionButton: UIButton!
    @IBOutlet var sendRequestButton: UIButton!

    var topicId: Int?
    var leaderQuestions: [Question] = []
    var memberQuestions: [Question] = []

    var delegate: SurveyRequestDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    private func setUpView() {
        addNewQuestionButton.layer.borderWidth = 1
        addNewQuestionButton.layer.cornerRadius = 5
        sendRequestButton.layer.cornerRadius = 5
    }

    @IBAction func addNewQuestionButtonTapped(_ sender: Any) {
        updateMemberQuestions()
        let newQuestion = Question(body: "", type: "TEXT", leader: false)
        memberQuestions.append(newQuestion)
        tableView.reloadData()
    }

    @IBAction func sendRequestButtonTapped(_ sender: Any) {
        updateMemberQuestions()
        let allQuestions: [Question] = leaderQuestions + memberQuestions
        postSurveyRequest(questions: allQuestions)
    }

    private func updateMemberQuestions() {
        var cells = [AnswersTableViewCell]()
        for cellNumber in 0...tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: cellNumber, section: 0)) as? AnswersTableViewCell {
                cells.append(cell)
            }
        }

        var responses: [Question] = []
        for cell in cells {
            guard let memberQuestion = cell.answerTextView.text else { return }
            let response = Question(body: memberQuestion, type: "TEXT", leader: false)
            responses.append(response)
        }
        memberQuestions = responses
    }

    private func postSurveyRequest(questions: [Question]) {
        guard let topicId = topicId else {
            NSLog("Failed to get topicId")
            return
        }
        UserController.shared.sendSurveyRequest(with: questions, topicId: topicId) { result in
            guard let result = result else {
                self.errorSendingRequestAlert()
                print("Failed to get result from server")
                return
            }
            DispatchQueue.main.async {
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: SurveyViewController.self) {
                        self.navigationController?.popToViewController(controller, animated: true)
                        self.delegate?.didGetSurveyRequest(result)
                    }
                }
            }
        }
    }
}

extension RequestMemberViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberQuestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestMemberCell", for: indexPath) as? AnswersTableViewCell else {
            return UITableViewCell()
        }
        cell.questionLabel.text = "Question \(indexPath.row + 1)"
        cell.answerTextView.text = memberQuestions[indexPath.row].body
        cell.answerTextView.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            memberQuestions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
