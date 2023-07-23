import UIKit

enum MyError: String, Error {
    case invalidURL = "URL string provided is not valid"
    case emptyData = "Data received is empty!"
    case invalidData = "Data cannot be decoded to a required Type"
    case receivedError = "Received error"
    case statusCodeNot200 = "HTTPURLResponse success code is 200, but recived different!!"
    case unknown = "Unknown Error, could be that the given data was not valid JSON!"
}

struct RandomUser: Codable {
    let results: [RandomResults]?
    let info: RandomInfo?
}

struct RandomResults: Codable {
    let gender: String?
    let name: RandomResultsName?
}

struct RandomResultsName: Codable {
    let title: String?
    let first: String?
    let last: String?
}

struct RandomInfo: Codable {
    let seed: String?
    let results: Int?
    let page: Int?
    let version: String?
}

func getRandomUser(urlString: String, completion: @escaping (Result<RandomUser, MyError>) -> Void) {
 
    guard let url = URL(string: urlString) else {
        completion(.failure(.invalidURL))
        return
    }
    
    let _ = URLSession.shared.dataTask(with: url) { data, response, error in
        if let _ = error {
            debugPrint("Received Error = \(String(describing: error))")
            completion(.failure(.receivedError))
            return
        }
        
        guard let data = data else {
            completion(.failure(.emptyData))
            return
        }
        
        do {
            let result = try JSONDecoder().decode(RandomUser.self, from: data)
            completion(.success(result))
        } catch(MyError.invalidData) {
            completion(.failure(.invalidData))
        } catch {
//            print("Error = \(error)")
            completion(.failure(.unknown))
        }
    }.resume()
}

let randomUserEndpoint = "https://randomuser.me/api"

getRandomUser(urlString: randomUserEndpoint) { result in
    switch result {
    case .success(let aRandomUser):
        print("User is \(String(describing: aRandomUser.results?.first?.name))")
    case .failure(let error):

        print("Error received in .failure = \(error) , and error.rawValue = \(error.rawValue)")

        // Can do actions for individual errors
        switch error {
        case .emptyData:
            print("Action for: Empty data received")
        case .invalidURL:
            print("Action for: Provided ULR is not valid")
        case .invalidData:
            print("Action for: Recieved data does not match to the model")
        case .unknown:
            print("Action for: Some unknow error")
        case .receivedError:
            print("Action for: Empty data received")
        case .statusCodeNot200:
            print("Action for: Status code not between 200...299")
        }
    }
}

// Using async/await

// Using async/await and returning ResultSet type

func getRandomUserAsyncWithResultSet(urlString: String) async throws -> Result<RandomUser, MyError> {
    
    guard let url = URL(string: urlString) else {
        return .failure(.invalidURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard !data.isEmpty else {
        return .failure(.emptyData)
    }
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        print("Looking for statusCode 200 but received \(httpResponse.statusCode)")
        return .failure(.statusCodeNot200)
    }
        
    guard let aRandomUser = try? JSONDecoder().decode(RandomUser.self, from: data) else {
        return .failure(.invalidData)
    }
    
    return .success(aRandomUser)
}

// Using async/await and returning RandomUser type

func getRandomUserAsyncWithoutResultSet(urlString: String) async throws -> RandomUser {
    
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
        
    guard let aRandomUser = try? JSONDecoder().decode(RandomUser.self, from: data) else {
        throw MyError.invalidData
    }
    
    return aRandomUser
}



//  Since do { try await } in Playground crashes, just import Foundation and wrap the code in a detached task

Task {
    do {
        let result = try await getRandomUserAsyncWithoutResultSet(urlString: randomUserEndpoint)
        print("\n\n result from getRandomUserAsyncWithoutResult")
        print(result)
    } catch MyError.invalidURL {
        print("InvalidURL is thrown")
    } catch MyError.invalidData {
        print("InvalidData is thrown")
    // //Continue catching individual error or just catch all with let error as below
    } catch (let error) {
        print("Got error = \(error)")
    }
}

Task {
    do {
        let result = try await getRandomUserAsyncWithResultSet(urlString: randomUserEndpoint)
        print("\n\n result from getRandomUserAsyncWithResult")
        switch result {
            case .success(let aRandomUser):
            print("Printing Random User")
                print(aRandomUser)
        case .failure(.invalidURL):
            print("Received InvalidURL Error")
        case .failure(.emptyData):
            print("Received EmptyData Error")
        // //Continue catching individual error or just catch all with let error as below
        case .failure(let error):
            print("Failure with let error = \(error)")
        }
    } catch {
        print("Inside getRandomUserAsyncWithResult catch")
    }
}

