//
//  MockedData.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import Foundation
@testable import GitHub_Watcher

/// Contains all available Mocked data.
final class MockedData {
    
    // users
    
    static let RingoStarr_JSON: URL = Bundle.module.url(forResource: "Ringo Starr", withExtension: "json")!
    static let JennaOrtega_JSON: URL = Bundle.module.url(forResource: "Jenna Ortega", withExtension: "json")!
    static let funnyboxPage1_JSON: URL = Bundle.module.url(forResource: "funnybox1", withExtension: "json")!
    static let funnyboxPage2_JSON: URL = Bundle.module.url(forResource: "funnybox2", withExtension: "json")!
    
    
    static let ringoRequestURL = URL(string: "https://api.github.com/search/users?q=Ringo%20Starr&per_page=12&page=1")!
    
    static let jennaRequestURL = URL(string: "https://api.github.com/search/users?q=Jenna%20Ortega&per_page=12&page=1")!
    
    static let funnyRequestURL1 = URL(string: "https://api.github.com/search/users?q=funnybox&per_page=12&page=1")!
    
    static let funnyRequestURL2 = URL(string: "https://api.github.com/search/users?q=funnybox&per_page=12&page=2")!
    
    
    static let ringo1 = User(id: 7989216,
                             login: "exp0se",
                             avatarUrl: "https://avatars.githubusercontent.com/u/7989216?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/exp0se/repos")
    static let ringo2 = User(id: 46558499,
                             login: "MaxMukovin",
                             avatarUrl: "https://avatars.githubusercontent.com/u/46558499?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/MaxMukovin/repos")
    static let ringo3 = User(id: 45846367,
                             login: "starringo23",
                             avatarUrl: "https://avatars.githubusercontent.com/u/45846367?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/starringo23/repos")
    static let ringoUsers = Users(totalCount: 3, items: [ringo1, ringo2, ringo3])
    
    
    static let jenna1 = User(id: 120311953,
                             login: "jenna0rtega",
                             avatarUrl: "https://avatars.githubusercontent.com/u/120311953?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/jenna0rtega/repos")
    static let jenna2 = User(id: 123633160,
                             login: "JennaOrtega12",
                             avatarUrl: "https://avatars.githubusercontent.com/u/123633160?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/JennaOrtega12/repos")
    static let jennaUsers = Users(totalCount: 2, items: [jenna1, jenna2])
    
    
    static let funny1 = User(id: 3070149,
                             login: "FunnyBox",
                             avatarUrl: "https://avatars.githubusercontent.com/u/3070149?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/FunnyBox/repos")
    static let funny2 = User(id: 122557272,
                             login: "FunnyBoxCTI-org",
                             avatarUrl: "https://avatars.githubusercontent.com/u/122557272?v=4",
                             type: "Organization",
                             reposUrl: "https://api.github.com/users/FunnyBoxCTI-org/repos")
    static let funny3 = User(id: 5155099,
                             login: "funnybox12",
                             avatarUrl: "https://avatars.githubusercontent.com/u/5155099?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/funnybox12/repos")
    static let funny4 = User(id: 38210635,
                             login: "funnybox67",
                             avatarUrl: "https://avatars.githubusercontent.com/u/38210635?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/funnybox67/repos")
    static let funny5 = User(id: 99987004,
                             login: "Funnyboxzz",
                             avatarUrl: "https://avatars.githubusercontent.com/u/99987004?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/Funnyboxzz/repos")
    static let funny6 = User(id: 84263161,
                             login: "FunnyboxXD",
                             avatarUrl: "https://avatars.githubusercontent.com/u/84263161?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/FunnyboxXD/repos")
    static let funny7 = User(id: 122556903,
                             login: "funnyboxcti",
                             avatarUrl: "https://avatars.githubusercontent.com/u/122556903?v=4",
                             type: "User",
                             reposUrl: "https://api.github.com/users/funnyboxcti/repos")
    static let funnyUsers = Users(totalCount: 7, items: [funny1, funny2, funny3, funny4, funny5, funny6, funny7])
    
    // repos
    
    static let ringoRepos_JSON: URL = Bundle.module.url(forResource: "ringo repos", withExtension: "json")!
    static let brokenRepos_JSON: URL = Bundle.module.url(forResource: "broken repos", withExtension: "json")!
    static let ringoRepo2Contributors_JSON: URL = Bundle.module.url(forResource: "ringo repo2 contributors", withExtension: "json")!
    static let ringoRepo2Languages_JSON: URL = Bundle.module.url(forResource: "ringo repo2 languages", withExtension: "json")!
    static let brokenContributors_JSON: URL = Bundle.module.url(forResource: "broken contributors", withExtension: "json")!

    static let ringoReposURL = URL(string:"https://api.github.com/users/starringo23/repos")!
    static let ringoRepo2ContributorsURL = URL(string: "https://api.github.com/repos/starringo23/Web-Dev/contributors")!
    static let ringoRepo2LanguagesURL = URL(string: "https://api.github.com/repos/starringo23/Web-Dev/languages")!
    
    static let ringoRepo1 = Repo(
        id: 241804939,
        name: "FreeZiing",
        private: false,
        url: "https://api.github.com/repos/starringo23/FreeZiing",
        contributorsUrl: "https://api.github.com/repos/starringo23/FreeZiing/contributors",
        languagesUrl: "https://api.github.com/repos/starringo23/FreeZiing/languages",
        owner: ringo3,
        description: "XAXAXAXAXAXAXAXAXAXAXAX",
        createdAt: try! Date("2020-02-20T05:53:45Z", strategy: .iso8601))
    static let ringoRepo2 = Repo(
        id: 241805166,
        name: "Web-Dev",
        private: false,
        url: "https://api.github.com/repos/starringo23/Web-Dev",
        contributorsUrl: "https://api.github.com/repos/starringo23/Web-Dev/contributors",
        languagesUrl: "https://api.github.com/repos/starringo23/Web-Dev/languages",
        owner: ringo3,
        description: nil,
        createdAt: try! Date("2020-02-20T05:54:57Z", strategy: .iso8601))
    static let ringoRepos = [ringoRepo1, ringoRepo2]
    
    static let ringoRepo2Contributor1 = User(
        id: 45846367,
        login: "starringo23",
        avatarUrl: "https://avatars.githubusercontent.com/u/45846367?v=4",
        type: "User",
        reposUrl: "https://api.github.com/users/starringo23/repos")
    static let ringoRepo2Contributors = Contributors([ringoRepo2Contributor1])
    
    static let ringoRepo2Language1 = Language(
        name: "HTML",
        value: 100,
        color: .black)
    static let ringoRepo2Languages = Languages([ringoRepo2Language1])
}

