import Foundation
import CoreData

public extension NSManagedObjectID {
  func humanReadableRepresentation(hideEntityName: Bool) -> String {
    return uriRepresentation().humanReadableRepresentation(interpretAsTemporaryURL: isTemporaryID, hideEntityName: hideEntityName)
  }
}

extension URL {
  func humanReadableRepresentation(interpretAsTemporaryURL isTemporary: Bool, hideEntityName: Bool) -> String {
    let components = pathComponents
    guard components.count >= 2 else {
      return absoluteString // Fallback
    }
    
    // Get the last one/two Components
    let importantComponents = Array(components[components.count - 2..<components.count])

    let entityName = importantComponents[0]
    let ID = importantComponents[1]
    var readableID = ID
    if isTemporary {
      let IDComponentns = ID.components(separatedBy: "-")
      readableID = "t…".appending(IDComponentns.last ?? "")
    }
    
    var result = ""
    
    if hideEntityName == false {
      result += "\(entityName)/"
    }
    result += readableID
    return result;
  }
}
