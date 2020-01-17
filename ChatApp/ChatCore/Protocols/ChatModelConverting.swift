//
//  ChatModelConverting.swift
//  ChatCore
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatModelConverting {
    associatedtype Networking: ChatNetworkServicing
    associatedtype MUI: MessageRepresenting
    associatedtype CUI: ConversationRepresenting
    associatedtype MSUI: MessageSpecifying
    associatedtype USRUI: UserRepresenting
    
    func convert(messageSpecification: MSUI) -> Networking.MS

    func convert(message: Networking.M) -> MUI

    func convert(conversation: Networking.C) -> CUI

    func convert(user: Networking.U) -> USRUI
    
}
