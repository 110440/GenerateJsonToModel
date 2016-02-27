//: Playground - noun: a place where people can play

import UIKit

//// 生成代码模板 /////////

// 生成的 model 遵守的两个协议 ，协议请看下面
let protocol1 = "TSwiftyJSONAble"
let protocol2 = "TToDictionaryAble"



////////////////////////////////////////// 测试生成的 model 正确性使用(将结果复制到尾部) ////////////////////
public protocol TSwiftyJSONAble {
    init?(json:JSON)
}

public protocol TToDictionaryAble{
    func toDictionary()->Dictionary<String,AnyObject>
}

extension String{
    func firstUp()->String{
        let firstChar = self.substringToIndex(self.startIndex.advancedBy(1) )
        let otherChars = self.substringFromIndex(self.startIndex.advancedBy(1))
        return firstChar.uppercaseString + otherChars
    }
}

extension NSNumber{
    func getBaseType()->String{
        
        let int: Int = 0
        let float: Float = 0.0
        let double: Double = 0.0
        
        let intNumber: NSNumber = int
        let floatNumber: NSNumber = float
        let doubleNumber: NSNumber = double
        
        let intTag      = String.fromCString(intNumber.objCType)!
        let floatTag    = String.fromCString(floatNumber.objCType)!
        let doubleTag   = String.fromCString(doubleNumber.objCType)!
        
        let typeTag = String.fromCString(self.objCType)
        switch typeTag!{
        case intTag:
            return "Int"
        case floatTag:
            return "Float"
        case doubleTag:
            return "Double"
        default:
            print(" 未知 NSNumber objCType:\(typeTag!) ")
            return "未知Number"
        }
    }
}

//MARK:- base type TSwiftyJSONAble

extension String:TSwiftyJSONAble{
    public init?(json: JSON) {
        self = json.stringValue
    }
}

extension Int:TSwiftyJSONAble{
    public init?(json: JSON) {
        self = json.intValue
    }
}

extension Float:TSwiftyJSONAble{
    public init?(json: JSON) {
        self = json.floatValue
    }
}

extension Double:TSwiftyJSONAble{
    public init?(json: JSON) {
        self = json.doubleValue
    }
}

public extension JSON{
    
    func toObject<T:TSwiftyJSONAble>(objectType:T.Type)->T?{
        return objectType.init(json: self)
    }
    
    func toObjectArray<T:TSwiftyJSONAble>(objectType:T.Type)->[T]{
        return self.arrayValue
            .map({ objectType.init(json: $0) }) // Map to T
            .filter({ $0 != nil }) // Filter out failed objects
            .map({ $0! }) // Cast to non optionals array
    }
}

// toDictionary 使用的 把 数组 按类型转成 AnyObject
func TTparseObjArrayToAnyObjArray(obj:Array<AnyObject>?)-> Array<AnyObject>?{
    
    guard let obj = obj else { return nil }
    guard obj.count > 0 else { return nil }
    
    
    switch obj.first {
    case _ as String , _ as Int ,_ as Float , _ as Double , _ as Bool:
        return obj.flatMap{ $0 }
    case _ as TToDictionaryAble:
        return obj.flatMap{ ($0 as! TToDictionaryAble).toDictionary() }
    default:
        fatalError("==== toDictionary unkonw type ")
        break
    }
    return nil
}
///////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////// core /////////////////////////////////////

class VarItem{
    var name:String
    var typeStr:String
    var type:Type
    
    init(name:String,typeStr:String,type:Type){
        self.name = name
        self.typeStr = typeStr
        self.type = type
    }
}

extension VarItem:Equatable{}

func ==(lhs: VarItem, rhs: VarItem) -> Bool{
    if lhs.name == rhs.name && lhs.typeStr == rhs.typeStr && lhs.type == rhs.type {
        return true
    }
    return false
}

class Obj{
    
    var items = [VarItem]()
    var childs = [Obj]()
    var name:String
    
    var  father:Obj?
    
    //t
    var t1:String {
        get{
            var t = ""
            var father = self.father
            while let _ = father{
                t += "\t"
                father = father?.father
            }
            return t
        }
    }
    var t2:String{
        get{
            return self.t1 + "\t"
        }
    }
    var t3:String{
        get{
            return self.t2 + "\t"
        }
    }
    
    init(name:String, json:JSON){
        self.name = name
        
        for case let(k,v) in json{
            
            //print("key:\(k) value:\(v)")
            
            switch v.type {
                
            case .Number:
                let typerStr = v.numberValue.getBaseType()
                let item = VarItem(name: k, typeStr: typerStr,type:v.type)
                self.items.append(item)
            case .String:
                let item = VarItem(name: k, typeStr: "String",type:v.type)
                self.items.append(item)
            case .Bool:
                let item = VarItem(name: k, typeStr: "Bool",type:v.type)
                self.items.append(item)
            case .Dictionary:
                
                let item = VarItem(name: k, typeStr: k.firstUp() ,type:v.type)
                self.items.append(item)
                
                let obj = Obj(name: k.firstUp(), json: v )
                obj.father = self
                self.childs.append(obj)
            case .Array:
                
                if let jsonObj = v.array?.first{
                    
                    switch jsonObj.type {
                    case .Number:
                        let typerStr = v.numberValue.getBaseType()
                        let item = VarItem(name: k, typeStr: "[\(typerStr)]",type:v.type)
                        self.items.append(item)
                    case .String:
                        let item = VarItem(name: k, typeStr: "[String]",type:v.type)
                        self.items.append(item)
                    case .Dictionary:
                        
                        let item = VarItem(name: k, typeStr: "[\(k.firstUp())]" ,type:v.type)
                        self.items.append(item)
                        
                        let obj = Obj(name: k.firstUp(), json: jsonObj )
                        obj.father = self
                        self.childs.append(obj)
                    default:
                        let item = VarItem(name: k, typeStr: "[未知类型]" ,type:v.type)
                        self.items.append(item)
                    }
                    
                }else{
                    let item = VarItem(name: k, typeStr: "[未知类型]" ,type:v.type)
                    self.items.append(item)
                }
                
                
            default:
                let item = VarItem(name: k, typeStr: "未知类型" ,type:v.type)
                self.items.append(item)
            }
        }
    }
    
    func generateObjBeginCodeStr()->String{
        return self.t1 + "class \(self.name):\(protocol1),\(protocol2) {\n\n"
    }
    
    func generateObjEndCodeStr()->String{
        return self.t1 + "}\n"
    }
    
    
    func generateVarItemCodeStr()->String{
        
        var bodyStr = ""
        let t_str = self.t2
        for item in self.items{

            let varName = item.name
            let varType = item.typeStr
            let line = t_str + "var \(varName):\(varType)?\n"
            bodyStr += line
        }
        return bodyStr + "\n"
    }
    
    func generateChildsCodeStr()->String{
        
        var codeStr = ""
        for child in self.childs{
            let str = child.generateObjCodeStr()
            codeStr += str + "\n"
        }
        return codeStr
    }
    
    //MARK:- init from SwiftyJSON
    func generateFromJSONObjFuncStr()->String {
        let funcNameStr = self.t2 + "required init?(json:JSON) {\n"
        let funcEndStr = self.t2 + "}\n\n"
        
        var funcBodyStr = ""
        for item in self.items{

            switch item.type{
            case .Number:
                let typeStr = item.typeStr
                funcBodyStr += self.t3 + "self.\(item.name) = json[\"\(item.name)\"].\(typeStr.lowercaseString)\n"
            case .Bool:
                funcBodyStr += self.t3 + "self.\(item.name) = json[\"\(item.name)\"].bool\n"
            case .String:
                funcBodyStr += self.t3 + "self.\(item.name) = json[\"\(item.name)\"].string\n"
            case .Dictionary:
                funcBodyStr += self.t3 + "self.\(item.name) = json[\"\(item.name)\"].toObject(\(item.typeStr)) \n"
            case .Array:
                //去掉[]符号
                let str = item.typeStr
                let objTypeStr = str.substringWithRange(Range(start:str.startIndex.advancedBy(1),end:str.endIndex.advancedBy(-1)))
                funcBodyStr += self.t3 + "self.\(item.name) = json[\"\(item.name)\"].toObjectArray(\(objTypeStr)) \n"
            default:
                break
            }

        }
        
        //增加一个无参数init()
        let initFunc = self.t2 + "init(){ }\n\n"
        return funcNameStr + funcBodyStr + funcEndStr + initFunc
    }
    
    //MARK:- to Dictionary func code string
    func generateToDictionaryFuncCodeStr()->String{
        let funcNameStr = self.t2 + "func toDictionary()->Dictionary<String,AnyObject>{\n"
        let funcEndStr = self.t2 + "}\n\n"
        var funcBodyStr = ""
        funcBodyStr += self.t3 + "var dic = [String:AnyObject]()\n" //声明
        
        for item in self.items{
            
            switch item.type{
            case .Number , .Bool , .String:
                funcBodyStr += self.t3 + "dic[\"\(item.name)\"] = self.\(item.name) \n"
            case .Dictionary:
                funcBodyStr += self.t3 + "dic[\"\(item.name)\"] = self.\(item.name)?.toDictionary() \n"
            case .Array:
                funcBodyStr += self.t3 + "dic[\"\(item.name)\"] = TTparseObjArrayToAnyObjArray(self.\(item.name))\n"
            default:
                break
            }
        }
        let returnStr = self.t3 + "return dic \n"
        return funcNameStr + funcBodyStr + returnStr + funcEndStr
    }
    
    // MARK:- 生成对象Model全部代码
    func generateObjCodeStr()->String{
        let begin = self.generateObjBeginCodeStr()
        let body = self.generateVarItemCodeStr()
        let end = self.generateObjEndCodeStr()
        
        let fromDicStr = self.generateFromJSONObjFuncStr()
        let toDicStr = self.generateToDictionaryFuncCodeStr()
        
        let childCodeStr = self.generateChildsCodeStr()
        
        let objCodeStr = begin + childCodeStr + body + fromDicStr + toDicStr + end
        
        return objCodeStr
    }
}

///////////////////////////////////////////// main run ////////////////////////////////////////////////

//let inputFileUrl = [#FileReference(fileReferenceLiteral: "input.json")#]
//let inputData = NSData(contentsOfURL: inputFileUrl)

let inputData = NSData(contentsOfFile:NSBundle.mainBundle().pathForResource("input", ofType: "json")!)
let jsonString = NSString(data: inputData!, encoding: NSUTF8StringEncoding)
//print(jsonString)

let json = JSON(data: inputData!)

let obj = Obj(name: "TestModel" ,json: json )

let codeStr = obj.generateObjCodeStr()
print(codeStr)


/////////////////// 请用自已的 JSON 替换 input.json 文件内容，然后查看输出,可以复制到下面验证 /////////////////////

// 请粘贴生成的mode 到这里//


