import Foundation

final class NetworkAPI {
    
    public static let shared = NetworkAPI()
    
    private init() {}
    
    private static let url = URL(string: "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json")!
    
    public func fetchData() async -> [Station] {
        
        return await withCheckedContinuation { continuation in
            
            let task = URLSession.shared.dataTask(with: NetworkAPI.url) { data, response, error in
                
                guard let data, error == nil else {
                    continuation.resume(returning: [])
                    return
                }
                
                var stations: [Station]?
                do {
                    stations = try JSONDecoder().decode([Station].self, from: data)
                }
                catch {
                    print("🔸", "Failed to decode JSON.")
                    continuation.resume(returning: [])
                }
                
                guard let stations, !stations.isEmpty else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: stations)
            }
            
            task.resume()
        }
    }
}

struct Station: Codable {
    let sno: String //站點編號
    let sna: String //站點名稱
    let tot: Int //站點總停車格數
    let sbi: Int //目前車輛數
    let sarea: String //行政區 ex.大安區、中山區
    let mday: String //微笑單車各場站來源資料更新時間
    let lat: Double //緯度
    let lng: Double //經度
    let ar: String //地址
    let sareaen: String //英文行政區 ex.大安區、中山區
    let snaen: String //英文站點名稱
    let aren: String //英文地址
    let bemp: Int //空位數量
    let act: String //站點目前是否禁用 ex."0"禁用中, "1"啟用中
    let srcUpdateTime: String //微笑單車系統發布資料更新的時間
    let updateTime: String //北市府交通局數據平台經過處理後將資料存入DB的時間
    let infoTime: String //微笑單車各場站來源資料更新時間
    let infoDate: String //微笑單車各場站來源資料更新時間
}
