//
//  LoginView.swift
//  timetrack
//
//  Created by 李崇兵 on 2020/11/24.
//

import SwiftUI
import Moya
import Alamofire
import Request
import Json


struct LoginView: View {
    @State var username:String
    @State var password:String
    
    var body: some View {
        Text("Hello, World! timetrack")
        TextField("username", text: $username, onCommit: {}).textFieldStyle(RoundedBorderTextFieldStyle())
            
        SecureField("password", text: $password){}.textFieldStyle(RoundedBorderTextFieldStyle())
        
        Button("login") {
            /*
             moya
             */
            
//
//            let provider = MoyaProvider<TimeTrackService>()
//            provider.request(.login(username: self.username, password: self.password)) { result in
//                // do something with the result (read on for more details)
//
//
//            }
            /*
             Alamofire
             */

           
            struct Login: Encodable {
                let username: String
                let password: String
                let rememberMe:Int
                
            }

            let login = Login(username:self.username, password: self.password,rememberMe:1)

            AF.request("http://localhost:8080/auth/login",
                       method: .post,
                       parameters: login,
                       encoder: JSONParameterEncoder.default).response { response in
                        debugPrint(response.response ?? response)
                        
                        

            }
//            AF.request("http://localhost:8080/auth/login",
//                       method: .post,
//                       parameters: login,
//                       encoder: JSONParameterEncoder.default).responseJSON { response in
//                        debugPrint(response)
//                        }
            
        }
        
        Button("注册"){
            let provider = MoyaProvider<TimeTrackService>()
            provider.request(.createUser(username: self.username, password: self.password)){result in
                
            }
            
        }
        Button("获取任务列表"){
            let token = "eyeAm.AJsoN.weBTOKen"
            let authPlugin = AccessTokenPlugin { _ in token }
            let provider = MoyaProvider<TimeTrackService>(plugins: [authPlugin])
            provider.request(.tasks) { result in
                // do something with the result (read on for more details)
                
                           
            }
            
        }
            
    }
}






struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(username: "", password: "")
    }
}
enum TimeTrackService {
    case login(username: String, password: String)
    case showUser(id: Int)
    case createUser(username: String, password: String)
    case updateUser(id: Int, firstName: String, lastName: String)
    case tasks
}
extension TimeTrackService: TargetType,AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .login(_, _):
            return nil
        case .showUser(let id):
            return .bearer
        case .updateUser(let id, _, _):
        return .bearer
        case .createUser(_, _):
            return nil
        case .tasks:
            return .bearer
        }
        
    }
    
    var baseURL: URL { return URL(string: "http://localhost:8080")! }
    var path: String {
        switch self {
        case .login(_, _):
            return "/auth/login"
        case .showUser(let id), .updateUser(let id, _, _):
            return "/users/\(id)"
        case .createUser(_, _):
            return "/auth/register"
        case .tasks:
            return "/tasks"
        }
    }
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .showUser, .tasks:
            return .get
        case .createUser, .updateUser:
            return .post
        }
    }
    var task: Task {
        switch self {
        case .showUser, .tasks: // Send no parameters
            return .requestPlain
        case let .login(username, password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: JSONEncoding.default)
        case let .updateUser(_, firstName, lastName):  // Always sends parameters in URL, regardless of which HTTP method is used
            return .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: URLEncoding.queryString)
        case let .createUser(username, password): // Always send parameters as JSON in request body
            return .requestParameters(parameters: ["username": username, "password": password], encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        switch self {
        case .login:
            return "Half measures are as bad as nothing at all.".utf8Encoded
        case .showUser(let id):
            return "{\"id\": \(id), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".utf8Encoded
        case .createUser(let firstName, let lastName):
            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        case .updateUser(let id, let firstName, let lastName):
            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        case .tasks:
            // Provided you have a file named accounts.json in your bundle.
            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}





