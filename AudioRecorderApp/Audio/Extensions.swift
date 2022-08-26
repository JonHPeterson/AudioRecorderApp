//
//  Extensions.swift
//  AudioRecorderApp
//
//  Created by Jon Peterson on 8/26/22.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
