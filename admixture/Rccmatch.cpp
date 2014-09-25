#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <string>
#include <vector>
#include <queue>
#include <Rcpp.h>

#define MAX_V 2048
#define INF numeric_limits<double>::infinity()

using namespace std;
using namespace Rcpp;


typedef pair<double, int> Pair;
struct edge
{
    int to;
    int capacity;
    double cost;
    int rev;
};

int V; // number of vertices
vector<edge> graph[MAX_V]; // adjacency list of graph
double h[MAX_V]; // potential
double dist[MAX_V]; // minimum distance from s
int prevv[MAX_V]; // previous vertex
int preve[MAX_V]; // previous edge

void init()
{
    fill(prevv, prevv + V, 0);
    fill(preve, preve + V, 0);
    fill(graph, graph + V, vector<edge>());
    for (int i = 0; i < V; i++)
        graph[i].clear();
}

// add edge to graph
void add_edge(int from, int to, int capacity, double cost)
{
    graph[from].push_back((edge){to, capacity, cost, graph[to].size()});
    graph[to].push_back((edge){from, 0, -cost, graph[from].size() - 1});
}


// solve minimun cost flow problem from s to t to flow f
double min_cost_flow(int s, int t, int f)
{
    double ret = 0;
    fill(h, h + V, 0); // initialize h

    while (f > 0)
    {
        // Dijkstra algorithm
        priority_queue<Pair, vector<Pair>, greater<Pair> > que;
        fill(dist, dist + V, INF);
        dist[s] = 0;
        que.push(Pair(0, s));
        while (!que.empty())
        {
            Pair p = que.top();
            que.pop();
            int v = p.second;
            if (dist[v] < p.first)
                continue;
            for (int i = 0; i < (int)graph[v].size(); i++)
            {
                edge &e = graph[v][i];
                double d = dist[v] + e.cost + h[v] - h[e.to];
                if (dist[v] > d) d = dist[v]; // for rounding error
                if (e.capacity > 0 && dist[e.to] > d)
                {
                    dist[e.to] = d;
                    prevv[e.to] = v;
                    preve[e.to] = i;
                    que.push(Pair(dist[e.to], e.to));
                }
            }
        }

        // no solution
        if (dist[t] == INF)
            return -1;

        // update potential
        for (int v = 0; v < V; v++)
            h[v] += dist[v];

        int d = f;        
        for (int v = t; v != s; v = prevv[v])
            d = min(d, graph[prevv[v]][preve[v]].capacity);
        f -= d;
        ret += d * h[t];
        for (int v = t; v != s; v = prevv[v])
        {
            edge &e = graph[prevv[v]][preve[v]];
            e.capacity -= d;
            graph[v][e.rev].capacity += d;
        }
    }
    return ret;
}

Function asDataFrame("as.data.frame");

// [[Rcpp::export]]
DataFrame ccmatch(NumericMatrix x, int N) {
    int ncase = x.nrow(), ncontrol = x.ncol();

    int s = ncase + ncontrol, t = s + 1;
    V = t + 1;
    init();
    for (int i = 0; i < ncase; i++)
    {
        add_edge(s, i, N, 0);
        for (int j = 0; j < ncontrol; j++)
            add_edge(i, ncase + j, 1, x(i, j));
    }
    for (int j = 0; j < ncontrol; j++)
        add_edge(ncase + j, t, 1, 0);
  
    double min_cost = min_cost_flow(s, t, ncase * N);
    if (min_cost < 0)
    {
        puts("No solution found.");
        return NULL;
    }
    
    NumericMatrix mat(ncase, N + 2);
    for (int i = 0; i < ncase; i++)
    {
        mat(i, 0) = i + 1;
        double sum = 0;
        int count = 0;
        for (int j = 0; j < ncontrol; j++)
        {
            if (graph[ncase + j][i].capacity  == 1)
            {
                mat(i, ++count) = j + 1;
                sum += x(i, j);
                if (count == N) break;
            }
        }
        mat(i, N + 1) = sum;
    }
    
    CharacterVector colnames = CharacterVector::create("Case");
    for (char i = '1'; i - '1' < N; i++)
    {
        string str = "Control"; str += i;    
        colnames.push_back(str);
    }
    colnames.push_back("Distance");
    NumericVector rownames(ncase);
    for (int i = 0; i < ncase; i++)
        rownames[i] = i + 1;
    List dimnames = List::create(rownames, colnames);
    mat.attr("dimnames") = dimnames;

    DataFrame ret = asDataFrame(mat);
    return ret;
}