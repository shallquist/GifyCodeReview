//
//  DateFormatterCache.swift
//  Giphy
//
//  Created by Steven Bishop on 10/22/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation

struct DateFormatterCache {
    static var trendingDateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var trendedOnDateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }()
}
