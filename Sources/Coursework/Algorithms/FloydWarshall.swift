//
//  FloydWarshall.swift
//  Coursework
//
//  Created by k on 07.11.2026.
//

enum FloydWarshall {
    public static func makeDistanceMatrix(for graph: Graph) -> [[UInt?]] {
        // выглядит страшно но тут типа ээ будет двумерный массив из nil
        let n = Int(graph.vertexCount)
        var matrix = [[UInt?]](
            repeating: [UInt?](repeating: nil, count: n),
            count: n
        )
        
        for i in 0..<Int(graph.vertexCount) {
            matrix[i][i] = UInt(0);
        }
        
        for edge in graph.edges {
            let from = Int(edge.from);
            let to = Int(edge.to);
            
            matrix[from][to] = min(
                matrix[from][to] ?? edge.weight,
                edge.weight
            )
        }
        
        for k in matrix.indices {
            for i in matrix.indices {
                for j in matrix.indices {
                    guard let ik = matrix[i][k], let kj = matrix[k][j] else {
                        continue
                    }

                    let candidate = ik.addingReportingOverflow(kj)

                    if candidate.overflow {
                        continue
                    }

                    if let current = matrix[i][j] {
                        matrix[i][j] = min(current, candidate.partialValue)
                    } else {
                        matrix[i][j] = candidate.partialValue
                    }
                }
            }
        }
        
        return matrix;
    }
}
