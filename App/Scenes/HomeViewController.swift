import UIKit
import TelecomCore
import TelecomFeatures

final class HomeViewController: UITableViewController {
    private let viewModel: HomeViewModel
    private var token: ObservationToken?
    private var current = HomeState()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Minha Linha"
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in self?.reload() }, for: .valueChanged)
        token = viewModel.state.bind { [weak self] in self?.render($0) }
        reload()
    }

    private func reload() {
        Task { await viewModel.load() }
    }

    private func render(_ state: HomeState) {
        current = state
        if state.phase != .loading { refreshControl?.endRefreshing() }
        if case let .failed(message) = state.phase {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 3 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Consumo", "Fatura", "Pacotes extras"][section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return current.phase == .loaded ? 1 : 0
        case 1: return current.openInvoiceText == nil ? 0 : 1
        default: return current.offers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        switch indexPath.section {
        case 0:
            content.text = "\(current.planName) • \(current.phone)"
            content.secondaryText = current.usageText
            content.secondaryTextProperties.color = current.isNearLimit ? .systemRed : .secondaryLabel
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.progress = Float(current.usedRatio)
            bar.tintColor = current.isNearLimit ? .systemRed : .systemBlue
            bar.frame = CGRect(x: 0, y: 0, width: 80, height: 4)
            cell.accessoryView = bar
        case 1:
            content.text = current.openInvoiceText
            cell.accessoryType = .disclosureIndicator
        default:
            content.text = current.offers[indexPath.row].title
            content.secondaryText = Formatters.money(current.offers[indexPath.row].price)
            cell.accessoryType = .disclosureIndicator
        }
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 1: viewModel.didTapInvoices()
        case 2: viewModel.didTapOffer(id: current.offers[indexPath.row].id)
        default: break
        }
    }
}
