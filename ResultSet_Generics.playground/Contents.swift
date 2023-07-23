import Foundation
import UIKit

enum MyError: Error {
    case invalidURL
    case emptyData
    case invalidData
    case receivedError(Error?)
    case statusCodeNot200
    case unknown
}

/*
 Generic Result set returning [T] Type or error
 */

func getGenericResultSet<T: Decodable>(urlString: String, type: T.Type, completion: @escaping (Result<[T], MyError>) -> Void) {
    
    guard let url = URL(string: urlString) else {
        completion(.failure(.invalidURL))
        return
    }
    
    let _ = URLSession.shared.dataTask(with: url) { data, response, error in
        if let _ = error {
            completion(.failure(.receivedError(error)))
            return
        }
        
        guard let data = data else {
            completion(.failure(.emptyData))
            return
        }
        
        do {
            let result = try JSONDecoder().decode([T].self, from: data)
                completion(.success(result))
        } catch(MyError.invalidData) {
            completion(.failure(.invalidData))
        } catch {
//            print("Error = \(error)")
            completion(.failure(.unknown))
        }
    }.resume()
}

func getAsyncAwaitGenericResultSet<T: Decodable>(urlString: String, type: T.Type) async throws -> [T] {
    
    guard let url = URL(string: urlString) else {
        throw MyError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard !data.isEmpty else {
        throw MyError.emptyData
    }
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        print("Looking for statusCode 200 but received \(httpResponse.statusCode)")
        throw MyError.statusCodeNot200
    }

    guard let result = try? JSONDecoder().decode([T].self, from: data) else {
        throw MyError.invalidData
    }
    
    return result
}



struct GitUser: Codable {
    let login: String?
    let id: Int?
    let avatar_url: String?
    let url: String?
    let repos_url: String?
    let html_url: String?
    let followers_url: String?
    
    var following_url: String? {
        guard let url = url else { return nil}
        return "\(url)/following"
    }
    var gists_url: String? {
        guard let url = url else { return nil}
        return "\(url)/gists"
    }
}
 
let githubUsersEndpoint = "https://api.github.com/users"

getGenericResultSet(urlString: githubUsersEndpoint, type: GitUser.self) { result in
    print("\nInside getGenericResultSet")
    switch result {
    case .success(let allGitUsers):
//        print("Alll GitUsers = \(allGitUsers)")
        print("First GitUser = \(allGitUsers.first)")
    case .failure(let error):
        print("Error = \(error)")
        switch error {
        case .emptyData:
            print("Error: Empty data received")
        case .invalidURL:
            print("Error: Provided ULR is not valid")
        case .invalidData:
            print("Error: Recieved data does not match to the model")
        case .unknown:
            print("Error: Some unknow error")
        case .receivedError:
            print("Error: Empty data received")
        case .statusCodeNot200:
            print("Error: Did not get Success Reponse code of 200")
        }
    }
}


Task {
    do {
        print("\nInside getAsyncAwaitGenericResultSet")
        let allGitUsers = try await getAsyncAwaitGenericResultSet(urlString: githubUsersEndpoint, type: GitUser.self)
        print("\nGot success result in getAsyncAwaitGenericResultSet")
            //        print("Alll GitUsers = \(allGitUsers)")
                    print("First GitUser = \(allGitUsers.first)")
    } catch MyError.emptyData{
        print("Error thrown: Empty data received")
    } catch MyError.receivedError(let error){
        print("Error thrown: Received error = \(error)")
    } catch MyError.statusCodeNot200{
        print("Error thrown: Did not get Success Reponse code of 200")
    } catch MyError.invalidURL{
        print("Error thrown: Provided ULR is not valid")
    } catch MyError.invalidData{
        print("Error thrown: Recieved data does not match to the model")
    } catch {
        print("Error thrown: uncaught/unknown")
    }
}
