@main
struct Coursework {
    static func main() {
        let edges: [Edge] = [
            Edge(from: 0, to: 1, weight: 2),
            Edge(from: 1, to: 2, weight: 5),
            Edge(from: 0, to: 2, weight: 20),
            Edge(from: 2, to: 3, weight: 1)
        ]
        
        let demoGraph = Graph(vertexCount: 4, edges: edges);
        
        for edge in demoGraph.edges {
            print("\(edge.from) -> \(edge.to), W: \(edge.weight)")
        }
        
        let matrix = FloydWarshall.makeDistanceMatrix(for: demoGraph)

        for row in matrix {
            for column in row {
                guard let toPrint = column else {
                    print("· ", terminator: "")
                    continue
                }
                
                print("\(toPrint) ", terminator: "");
            }
            print("")
        }
    }
}
