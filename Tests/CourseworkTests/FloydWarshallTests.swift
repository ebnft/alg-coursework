import Testing
@testable import Coursework

@Suite("Флойд–Уоршелл")
struct FloydWarshallTests {
    @Test("Пустой граф возвращает пустую матрицу")
    func emptyGraph() {
        let graph = Graph(vertexCount: 0, edges: [])

        #expect(FloydWarshall.makeDistanceMatrix(for: graph).isEmpty)
    }

    @Test("Расстояние от единственной вершины до себя равно нулю")
    func singleVertex() {
        let graph = Graph(vertexCount: 1, edges: [])
        let expected: [[UInt?]] = [[0]]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Изолированные вершины остаются недостижимыми друг из друга")
    func disconnectedVertices() {
        let graph = Graph(vertexCount: 3, edges: [])
        let expected: [[UInt?]] = [
            [0, nil, nil],
            [nil, 0, nil],
            [nil, nil, 0],
        ]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Косвенный маршрут улучшает прямую дорогу без создания обратных рёбер")
    func shortestDirectedRoutes() {
        let graph = Graph(vertexCount: 4, edges: [
            Edge(from: 0, to: 1, weight: 2),
            Edge(from: 1, to: 2, weight: 5),
            Edge(from: 0, to: 2, weight: 20),
            Edge(from: 2, to: 3, weight: 1),
        ])
        let expected: [[UInt?]] = [
            [0, 2, 7, 8],
            [nil, 0, 5, 6],
            [nil, nil, 0, 1],
            [nil, nil, nil, 0],
        ]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Маршрут находится при несовпадении порядка вершин пути и их номеров")
    func intermediateVerticesInReverseOrder() {
        let graph = Graph(vertexCount: 4, edges: [
            Edge(from: 0, to: 3, weight: 2),
            Edge(from: 3, to: 2, weight: 3),
            Edge(from: 2, to: 1, weight: 4),
        ])
        let expected: [[UInt?]] = [
            [0, 9, 5, 2],
            [nil, 0, nil, nil],
            [nil, 4, 0, nil],
            [nil, 7, 3, 0],
        ]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Положительный цикл даёт маршруты в обоих направлениях, сохраняя нулевую диагональ")
    func positiveCycle() {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: 2),
            Edge(from: 1, to: 2, weight: 3),
            Edge(from: 2, to: 0, weight: 4),
        ])
        let expected: [[UInt?]] = [
            [0, 2, 5],
            [7, 0, 3],
            [4, 6, 0],
        ]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Нулевые рёбра и нулевой цикл не означают отсутствие пути")
    func zeroWeightCycle() {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: 0),
            Edge(from: 1, to: 0, weight: 0),
            Edge(from: 1, to: 2, weight: 4),
        ])
        let expected: [[UInt?]] = [
            [0, 0, 4],
            [0, 0, 4],
            [nil, nil, 0],
        ]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Из параллельных рёбер выбирается минимальное независимо от порядка", arguments: [false, true])
    func parallelEdges(reverseOrder: Bool) {
        let edges = [
            Edge(from: 0, to: 1, weight: 3),
            Edge(from: 0, to: 1, weight: 8),
        ]
        let graph = Graph(vertexCount: 2, edges: reverseOrder ? Array(edges.reversed()) : edges)
        let expected: [[UInt?]] = [[0, 3], [nil, 0]]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Петля не увеличивает расстояние до себя", arguments: [UInt(0), UInt(9), UInt.max])
    func selfLoop(weight: UInt) {
        let graph = Graph(vertexCount: 1, edges: [Edge(from: 0, to: 0, weight: weight)])
        let expected: [[UInt?]] = [[0]]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("UInt.max сохраняется как допустимый вес ребра")
    func maximumEdgeWeight() {
        let graph = Graph(vertexCount: 2, edges: [Edge(from: 0, to: 1, weight: UInt.max)])
        let expected: [[UInt?]] = [[0, UInt.max], [nil, 0]]

        #expect(FloydWarshall.makeDistanceMatrix(for: graph) == expected)
    }

    @Test("Сумма пути на верхней границе UInt сохраняется", arguments: [UInt(1), UInt(2)])
    func sumNearMaximum(lastWeight: UInt) {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: UInt.max - 2),
            Edge(from: 1, to: 2, weight: lastWeight),
        ])
        let matrix = FloydWarshall.makeDistanceMatrix(for: graph)

        #expect(matrix[0][2] == UInt.max - (2 - lastWeight))
    }

    @Test("Расстояние UInt.max распространяется через нулевое ребро")
    func maximumDistanceWithZeroWeightEdge() {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: UInt.max),
            Edge(from: 1, to: 2, weight: 0),
        ])
        let matrix = FloydWarshall.makeDistanceMatrix(for: graph)

        #expect(matrix[0][2] == UInt.max)
    }

    @Test("Непредставимая сумма остаётся nil согласно текущему поведению")
    func overflowingRouteHasNoRepresentableDistance() {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: UInt.max - 2),
            Edge(from: 1, to: 2, weight: 5),
        ])
        let matrix = FloydWarshall.makeDistanceMatrix(for: graph)

        #expect(matrix[0][1] == UInt.max - 2)
        #expect(matrix[1][2] == 5)
        #expect(matrix[0][2] == nil)
    }

    @Test("Переполнение обхода не заменяет конечный маршрут обрезанным числом")
    func finiteAlternativeSurvivesOverflow() {
        let graph = Graph(vertexCount: 3, edges: [
            Edge(from: 0, to: 1, weight: UInt.max - 2),
            Edge(from: 1, to: 2, weight: 5),
            Edge(from: 0, to: 2, weight: 20),
        ])
        let matrix = FloydWarshall.makeDistanceMatrix(for: graph)

        #expect(matrix[0][2] == 20)
    }
}
