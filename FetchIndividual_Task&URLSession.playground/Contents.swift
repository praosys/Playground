//  Understanding Fetching using 3 different ways
//
//  Created by Prasanna Rao.
//
import Foundation

struct File : Codable {
    let id: Int?
}

enum FileFetchError: Error {
    case invalidURL, invalidData, statusCodeNot200, fetchError(Error)
}

extension String {
//    static let fetchFileEndpooint = "https://fileholder.com/file/id/"
    static let fetchFileEndpooint = "https://api.github.com/users/"
}
 
protocol IndividualFileFetcherProtocol {
    func fetchResultSet(fileId: Int, completion: @escaping (Result<File, FileFetchError>) -> ())
    func fetch(fileId: Int, completion: @escaping (File?, FileFetchError?) -> ())
    func fetchAsyncAwait(fileId: Int) async throws -> File
}

class FetchIndividualFile: IndividualFileFetcherProtocol {
    
    func fetchResultSet(fileId: Int, completion: @escaping (Result<File, FileFetchError>) -> ()) {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            completion(.failure(.invalidURL))
            return
        }
                
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(.fetchError(error)))
                return
            }
            guard let data = data, let file = try? JSONDecoder().decode(File.self, from: data) else {
                completion(.failure(.invalidData))
                return
            }

            completion(.success(file))
            return
        }
        task.resume()
    }
    
    func fetch(fileId: Int, completion: @escaping (File?, FileFetchError?) -> ()) {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            completion(nil, .invalidURL)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, .fetchError(error))
                return
            }
            guard let data = data, let file = try? JSONDecoder().decode(File.self, from: data) else {
                completion(nil, .invalidData)
                return
            }

            completion(file, nil)
            return
        }
        task.resume()
    }
    
    func fetchAsyncAwait(fileId: Int) async throws -> File {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            throw FileFetchError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode != 200 {
            throw FileFetchError.statusCodeNot200
        }
        
        do {
            let file = try JSONDecoder().decode(File.self, from: data)
            return file
        } catch {
            throw FileFetchError.invalidData
        }
    }
}


// Test FetchIndividualFile

let individualFile1 = FetchIndividualFile()

// fetchResultSet(fileId: Int, completion: @escaping (Result<File, FileFetchError>) -> ())
individualFile1.fetchResultSet(fileId: 2) { result in
    switch result {
    case .success(let file):
        debugPrint("1. In FetchIndividualFile fetchResultSet, file = \(file)")
    case .failure(let error):
        debugPrint("1. In FetchIndividualFile fetchResultSet, error = \(error)")
    }
}

// fetch(fileId: Int, completion: @escaping (File?, FileFetchError?) -> ())
individualFile1.fetch(fileId: 5) { file, fileFetchError in
    if let file = file {
        debugPrint("2. In FetchIndividualFile fetch, file = \(file)")
    } else {
        debugPrint("1. In FetchIndividualFile fetch, error = \(fileFetchError)")
    }
}

// fetchAsyncAwait(fileId: Int) async throws -> File?
Task {
    do {
        let file = try await individualFile1.fetchAsyncAwait(fileId: 1)
        debugPrint("3. In FetchIndividualFile fetchAsyncAwait, file = \(file)")
    } catch (let error) {
        debugPrint("1. In FetchIndividualFile fetchAsyncAwait, thrown error = \(error)")
    }
}
