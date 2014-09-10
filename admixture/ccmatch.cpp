#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <vector>
#include <queue>

// Large File Support
#define _FILE_OFFSET_BITS 64

#define MAX_V 2048
#define N 2 // 1:N matched pair
#define INF numeric_limits<double>::infinity()

using namespace std;


typedef pair<int, int> Pair;
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
vector<int> prevv[MAX_V]; //previous vertex
int preve[MAX_V]; // previous edge

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

    prevv[t].push_back(0);
    while (f > 0)
    {
        // Dijkstra algorithm
        priority_queue<Pair, vector<Pair>, greater<Pair> > queue;
        fill(dist, dist + V, INF);
        dist[s] = 0;
        queue.push(Pair(0, s));
        while (!queue.empty())
        {
            Pair p = queue.top();
            queue.pop();
            int v = p.second;
            if (dist[v] < p.first)
                continue;
            for (int i = 0; i < graph[v].size(); i++)
            {
                edge &e = graph[v][i];
                double d = dist[v] + e.cost + h[v] - h[e.to];
                if (e.capacity > 0 && dist[e.to] > d)
                {
                    dist[e.to] = d;
                    prevv[e.to].push_back(v);
                    preve[e.to] = 1;
                    queue.push(Pair(dist[e.to], e.to));
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
        for (int v = t; v != s; v = prevv[v].back())
            d = min(d, graph[prevv[v].back()][preve[v]].capacity);
        f -= d;
        ret += d * h[t];
        for (int v = t; v != s; v = prevv[v].back())
        {
            edge &e = graph[prevv[v].back()][preve[v]];
            e.capacity -= d;
            graph[v][e.rev].capacity += d;
        }
    }

    return ret;
}


char* openfile(char* path)
{
    FILE* fp = fopen(path, "rb");
    off_t filesize;
    char* buf;

    if(!fp) goto LOAD_ERROR; //FILE NOT FOUND.

    fseek(fp, 0, SEEK_END);
    filesize = ftell(fp);
    buf = (char*)malloc(filesize);
    fseek(fp, 0, SEEK_SET);
    if(fread(buf, filesize, 1, fp) != 1) goto LOAD_ERROR; //FILE READ ERROR. OR MEMORY ALLOCATION ERROR.
    fclose(fp);

    return buf;

    LOAD_ERROR:
        // log_error("LOAD ERROR.\n");
        return NULL;
}

int strcnt(char* buf, char* str, char eos)
{
    char* bufptr;
    int count = 0;
    int n = strlen(str);
    for (bufptr = buf; *bufptr != eos; bufptr++)
        if (strncmp(bufptr, str, n) == 0)
            count++;

    return count;
}

void loaddata(double* distance, char* buf, int row, int col, char sep)
{
    char* bufptr = buf;
    char* bufptr2 = buf;
    for (int i = 0; i < row; i++)
    {
        bufptr2 = strchr(bufptr2, '\n');
        for (int j = 0; bufptr < bufptr2; j++, bufptr = strchr(bufptr, sep) + 1)
            distance[i * col + j] = atof(bufptr);
    }
}

int main(int argc, char* argv[])
{
    char* loadbuf = openfile(argv[1]);
    int row = strcnt(loadbuf, "\n", '\0'); // number of cases
    int col = strcnt(loadbuf, "\t", '\n') + 1; // number of controls

    printf("Case:    %d\n", row);
    printf("Control: %d\n", col);

    double* distance = new double[row * col];
    loaddata(distance, loadbuf, row, col, '\t');

    free(loadbuf);

    int vstart = 0, vend = MAX_V - 1;
    for (int i = 0; i < row; i++)
    {
        add_edge(vstart, i, 1, 0);
        for (int j = 0; j < col; j++)
        {
            add_edge(i, j, 1, distance[i * col + j]);
            add_edge(j, vend, N, 0);
        }
    }

    delete [] distance;

    int mcost = min_cost_flow(vstart, vend, row);
    for (int i = 0; i < col; i++)
    {
        vector<int>::iterator begin = prevv[i].begin(), end = prevv[i].end();
        for (; begin != end; ++begin)
            printf("%d\t", *begin);
        putchar('\n');
    }

    return 0;
}
