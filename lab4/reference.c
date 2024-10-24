int REMOVE(int, int);
int PUT(int, int);

int main() {
    int n; // the value of n will be stored in M[x3100]
    REMOVE(n, 0);
    return 0;
}

/**
 * @brief       remove the first n rings
 * @param n     the first n rings to be removed
 * @param state the state of all rings at now
 * @return      the state of all rings after these operations
 * @note        you should store the state of all rings at the specific memory
 */
int REMOVE(int n, int state) {
    if (n == 0)
        return state; // the state remains
    if (n == 1) {
        // TODO: change the 1st ring's state
        return /*all rings' state at now*/;
    }
    // TODO: REMOVE the first n-2 rings,
    // 		REMOVE the n-th ring,
    // 		PUT the first n-2 rings,
    // 		REMOVE the first n-1 rings
    return /*all rings' state at now*/;
}

/**
 * @brief       put the first n rings
 * @param n     the first n rings to be put
 * @param state the state of all rings at now
 * @return      the state of all rings after these operations
 * @note        you just need to inverse REMOVE
 */
int PUT(int n, int state) {
    // TODO
    return /*all rings' state at now*/;
}
