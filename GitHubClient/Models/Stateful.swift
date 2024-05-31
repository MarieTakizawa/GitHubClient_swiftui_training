import Foundation

enum Stateful<Value> {
    /// 読み込み中
    case loading
    /// 読み込み失敗、エラー保持
    case failed(Error)
    /// 読み込み完了、値を保持
    case loaded([Repo])
}
