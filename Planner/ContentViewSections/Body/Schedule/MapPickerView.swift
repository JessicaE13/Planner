import SwiftUI
import MapKit

struct IdentifiableMapItem: Identifiable, Hashable {
    let id = UUID()
    let mapItem: MKMapItem
}

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchResults: [IdentifiableMapItem] = []
    let onSelect: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a place", text: $searchText, onCommit: search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Map(coordinateRegion: $region, annotationItems: searchResults) { item in
                    MapMarker(coordinate: item.mapItem.placemark.coordinate, tint: .blue)
                }
                .frame(height: 300)
                List(searchResults, id: \.self) { item in
                    Button(action: {
                        let name = item.mapItem.name ?? "Selected Location"
                        let address = item.mapItem.placemark.title ?? ""
                        onSelect("\(name)\n\(address)")
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(item.mapItem.name ?? "Unknown")
                            Text(item.mapItem.placemark.title ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Pick Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                searchResults = items.map { IdentifiableMapItem(mapItem: $0) }
                if let first = items.first {
                    region.center = first.placemark.coordinate
                }
            }
        }
    }
}
