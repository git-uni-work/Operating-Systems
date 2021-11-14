||
|[ProgTest](https://progtest.fit.cvut.cz/index.php?X=Main)  ►  [BIE-OSY (20/21 LS)](https://progtest.fit.cvut.cz/index.php?X=Course&Cou=324)  ►  [Practice \#1](https://progtest.fit.cvut.cz/index.php?X=TaskGrp&Cou=324&Tgr=2051)  ►  **Cargo optimization**|[Logout](https://progtest.fit.cvut.cz/index.php?X=Logout)|

||
|**Cargo optimization**|

**Submission deadline:**

**2021-04-05 02:29:59**

 

**Evaluation:**

**30.0000**

**Max. assessment:**

**30.0000** (Without bonus points)

**Submissions:**

5 / 75

**Advices:**

0 / 0

The task is to develop a set of classes to optimize the profit from cargo transportation.

We assume there are ships suitable for cargo transportation. There are limits set for each such ship: the maximum weight (maxWeight) and maximum volume (maxVolume) of the cargo loaded. We must not exceed any of those two limits when loading the ship. Next, there is a destination set for each ship, the destination is an ordinary string.

Next, there are customers participating in the problem. The customers need to transport their cargo using our ship services. Based on a query, the customer answers a list of cargo to transport to the given destination. The list of cargo may be arbitrarily long (0, 1, 2, ..., N items in the list). There is a weight, a volume, and a fee associated with each cargo in the list (the fee is the price the customer is willing to pay for the transportation).

Your class `CCargoPlanner` will coordinate the transportation: it will query the customers, receive the cargo lists, and select the cargo to load on the ship. The choice of cargo is clear: we must not exceed the capacity of the ship while we want to maximize the profit (the sum of fees). Therefore, the ship may be loaded with a subset of the cargo our customers want to transport. The choice of cargo is simple: we may either load the cargo (the item from the cargo list), or not load the cargo. Fro example, there may be an item in the cargo list where the weight is 100, volume is 50, and fee is 1000. We may either load it (and reserve the weight and volume capacity), or skip it. We are not allowed to load only a part of it (e.g., weight 50, volume 25 and fee 500). Indeed, the choice of cargo is computationally very expensive. Therefore, we will use threads to increase the computation speed. Next, we will use threads to efficiently communicate with our customers.

An instance of `CCargoPlanner` is given the required number of threads to create for the computation (`workThreads`) and the number of threads to create for the salespersons (`salesThreads`). Next, `CCargoPlanner` receives asynchronous calls to a method, the method informs of a ship to load. The life cycle of `CCargoPlanner` is as follows:

-   an instance of `CCargoPlanner` is initialized,
-   the customers are registered (each customer is registered with a call to method `Customer`),
-   the computation is started (method `Start`). The method is given two parameters - the number of salesperson threads (`salesThreads`) and the number of work threads (`workThreads`). The method creates the required threads and lets them wait for the ship to load. As soon as the threads are ready, method `Start`returns to the caller,
-   the testing environment calls method `Ship` with each ship to load. The method may either called from the main threads, or from any other thread created by the testing environment. Method `Ship` must be very fast, it just receives the ship and returns to the caller. The method does not try to load the ship. Instead, it internally passes the ship to the salesperson and worker threads to do the computation,
-   the testing environment calls method `Stop` when there are no further ships to load. `CCargoPlanner` completes the computation (i.e., it loads all pending ships), finishes all salesperson and worker threads, and returns to the caller,
-   the instance of `CCargoPlanner` is destroyed.

The classes and their interface:

-   `CCargo` is a class representing a single item in the cargo list. It is very simple, it just encapsulates the weight, volume and transportation fee for the cargo.
-   `CShip` is a class that defines the common interface for all ship objects. The classes in the testing environment will be derived from this base class. A ship is defined by its capacity (`m_MaxWeight` and `m_MaxVolume`), and a destination (`m_Destination`). These attributes are filled in the constructor, and are accessible by the class interface:
    -   `Destination` retrieves ship's destination. The destination is unique for each ship,
    -   `MaxWeight` and `MaxVolume` retrieve the capacity of the ship,
    -   `Load` is used to load the ship's cargo. This method will be called by the worker thread when the optimal load is computed. The parameter is a list of cargo to load (`vector<CCargo>`). The order in the cargo list is not important. If there are more choices of cargo with equal profit, then any of them may be loaded.
-   `CCustomer` is a class that defines the common interface of a customer. The actual customers are derived from this base class. There is only one important method in the interface - method `Quote (dest, cargo) `. The method is used to retrieve the cargo list for the given destination. Your salesperson threads will call this method when an empty ship needs to be loaded. A call to this method may be very fast (it may return immediately), or it may take some time until the customer decides (therefore, the call may block one salesperson thread for a certain amount of time). The method may be concurrently called by several salesperson threads (e.g., with different destinations), this may speed up the processing.
-   `CCargoPlanner` is a class implemented by you. The class encapsulate all the processing (it receives the ships, accumulates the cargo lists from individual customers, selects the cargo for the ship, and loads the ship). The public interface is:
    -   a default constructor to initialize the instance. No threads is created in the constructor,
    -   method `Customer (x)`, the method registers customer `x`,
    -   method `Start ( salesThr, workThr )`, the method starts the threads (both salesperson and worker threads). The shall be prepared to receive the ships to handle. A call to `Start` returns immediately when the threads are created,
    -   method `Ship (x)`, the method adds a new ship `x` to load. The method internally passes the ship to the salesperson/work threads and returns. The method is not expected to do any time-consuming computation. Technically, a call to `Ship` almost immediately returns to the caller,
    -   method `Stop`, to stop the processing. The method waits until all pending ships are loaded and waits until all salesperson/worker threads are terminated. Finally, method `Stop` returns to the caller,
    -   class method `SeqSolver(cargo, maxWeight, maxVolume, load)`. The method is used to test the cargo selection algorithm itself. Parameters are: `cargo` (the cargo list to select the load from), `maxWeight` and `maxVolume` (ship's capacity), and `load` (output parameter - the selected cargo to load). The cargo to load must not exceed the ship's capacity and the selected cargo must sum fee as high as possible. Return value is the sum of fee of the selected cargo.
-   function `ProgtestSolver (cargo, maxWeight, maxVolume, load)` is a ready made implementation of the cargo selection algorithm. The interface matches the interface of `CCargoPlanner::SeqSolver` above. Your implementation may use this function for the core computation, or you may decide to implement the cargo selection algorithm by yourself. The last (bonus) test disables the function (it returns an empty cargo list), thus you must implement the algorithm by yourself if you want to pass the bonus.

The implementation is supposed to create the sales threads and work threads. The number of threads to create is given in parameters of `CCargoPlanner::Start`. When a new ship appears (method `Ship`), the ship is passed to the salesperson threads. These threads query the registered customers and retrieve cargo lists for the ship's destination. Thus the salesperson threads will call method `CCustomer::Quote`. The customers may respond immediately (i.e., the call returns without any delay), or the call may take some time (`Quote` will block). Therefore, it is important to use all your salesperson threads to serve the registered customers / destinations. A customer queried for destination X may block the calling thread for a long time, however, it may be concurrently queried by another salesperson thread for destination Y (and this query may have quick response). Do not use any fixed pattern to assign salesperson threads to the customers or ships, always use all available salesperson threads to do the missing queries. The testing environment tests for this behavior.

Once the cargo lists for the destination are collected, the program must find the cargo to actually load the ship. At this moment, the ship and the accumulated cargo list is passed from the salesperson threads to the work threads. The salesperson threads are not supposed to do the time-consuming computation, instead, these threads are designated to serve the customers. When the work threads finish the computation (either by the supplied `ProgtestSolver` function, or in your own implementation), the selected cargo must be loaded to the ship. A worker thread calls method `CShip::Load`, the method must be called exactly once for each ship.

If you decide to implement your own cargo selection algorithm, consider the following advice:

-   the problem is similar to the Knapsack problem. Indeed, it is an extension of the standard problem, there are two criteria to observe (the weight and the volume),
-   the basic solution of the Knapsack problem uses a recursion, the recursion tests all possible selections and requires an exponential time to finish. Such algorithm cannot be used, the problems in the test use up to 128 cargo items, thus the exponential algorithm will not finish in any reasonable time,
-   the problem may be solved using dynamic programming. The capacity of the ship is chosen to be reasonably small, both maxWeight and maxVolume is at most a few thousand. Therefore, the memory requirements of the dynamic programming algorithm are acceptable,
-   there are still many details in the design. An attention must be paid to parallelize the computation of a single problem instance (with a big ship capacity and many items in the cargo list). This is required for the last (bonus) test. The reference solution uses bitfield representation to decrease the memory requirements (there is approx 1 GiB of memory available). Note that there is at most 128 items in the cargo list.

* * * * *

Submit your source code containing the implementation of class `CCargoPlanner` with the required interface. You can add additional classes and functions, of course. Do not include function `main` nor `#include` directives to your implementation. The function `main` and `#include` directives can be included only if they are part of the conditional compile directive block (`#ifdef` / `#ifndef` / `#endif`).

Use the example implementation file included in the attached archive. Your whole implementation needs to be part of source file `solution.cpp`, the delivered file is only a stub. If you preserve compiler directives, you can submit file `solution.cpp` as a task solution.

You can use pthread or C++11 thread API for your implementation (see available \#include files). The Progtest uses g++ compiler version 8.3, this version handles most of the C++11, C++14, and C++17 constructs correctly.

* * * * *

**Hints:**

-   Start with the threads and synchronization, use the function from the attached library to solve the algorithmic problems. Once your program works with `ProgtestSolver`, you may replace this function with your own implementation.
-   To be able to use more CPU cores, serve as many ships and customers as possible, all in parallel. You need to simultaneously accept new ships, query customers, choose the load, and load the ships. Do not try to split these tasks into phases (i.e., receive all ships, then query the customers, ...). A solution based on this principle will not work. The tests in the testing environment are designed to cause a deadlock for such solution.
-   The instances of `CCargoPlanner` are created repeatedly for various inputs. Don't rely on global variable initialization. The global variables will have different values in the second, third, and further tests. An alternative is to initialize global variables always in constructor or `Start` method. Not to use global variables is even better.
-   Don't use mutexes and conditional variables initialized by `PTHREAD_MUTEX_INITIALIZER`. There are the same reasons as in the paragraph above. Use `pthread_mutex_init()` instead. Or use C++11 API.
-   The instances of ships and customers are allocated by the testing environment when smart pointers are initialized. They are deallocated automatically when all references are destroyed. Don't free those instances; it is sufficient to forget all copies of the smart pointers. On the other hand, your program has to free all resources it allocates.
-   The method (`CCustomer::Quote`) is reentrant and thread safe. Do not enclose calls to that method by a mutex - such serialization may unnecessarily decrease processing speed.
-   Don't use `exit`, `pthread_exit` or similar calls in `Stop` or in any other method. If `Stop` method does not return back to its caller, your program will be evaluated as wrong.
-   Use sample data in the attached files. You can find an example of API calls, several test data sets, and the corresponding results there.
-   The test environment uses STL. Be careful as the same STL container must not be accessed from multiple threads concurrently. You can find more information about STL parallel access in [C++ reference - thread safety.](http://en.cppreference.com/w/cpp/container)
-   Test environment has a limited amount of memory. There is no explicit limit, but the virtual machine, where tests are run has RAM size limited to 4 GiB. Your program is guaranteed at least 1 GiB of memory (i.e., data segment + stack + heap). The rest of the physical RAM is used by OS, and other processes.
-   If you decide to pass the bonus test, be careful to use proper granularity of parallelism. The input problem must be divided into several subproblems to pass the bonus tests. On the other hand, if there are too many small problems, context switches induce a high overhead. The reference solution limits the maximum number of problems concurrently solved by the worker threads to avoid this overhead.
-   The time intensive computation must be handled in the worker threads. The number of worker threads is determined by the parameter of method `Start`. The testing environment rejects a solution that does time-intensive computation outside these threads (e.g. in the salesperson threads).

* * * * *

**What do the particular tests mean:**

**Test algoritmu (sekvencni) [Algorithm test]**  
The test environment calls methods `SeqSolver()` for various inputs and checks the computed results. The purpose of the test is to check your algorithm. No instance of `CCargoPlanner` is created, no `Start` method is called. You can check whether your implementation is fast enough with this test. The test data are randomly generated.

**Základní test [Basic test]**  
The test environment creates an instance of `CCargoPlanner` for different number of salesperson threads (S=xxx), worker threads (W=xxx), and customers (C=xxx).

**Základní test, prubezna obsluha lodi [continuous ship service]**  
The test is similar to the basic test, moreover, the test checks that ships are served continuously. If they are not, the test ends in a deadlock (efficiently, it exceeds the time limit).

**Základní test, prubezna obsluha zakazniku [continuous customer service]**  
The test is similar to the basic test, moreover, the test checks whether the salesperson threads are dynamically dispatched to serve the registered customers. If the salesperson threads are not dispatched dynamically, the test ends up in a deadlock (exceeds time limit).

**Test zrychleni vypoctu [Speedup test]**  
The test environment runs your implementation with a various number of worker threads using the same input data. The test measures the time required for the computation (wall and CPU times). As the number of worker threads increases, the wall time should decrease, and CPU time can slightly increase (the number of worker threads is below the number of physical CPU cores). If the wall time does not decrease or does not decrease enough, the test is failed. For example, the wall time shall drop to 0.5 of the sequential time if two worker threads are used. In reality, the speedup will not be 2. Therefore, there is some tolerance in the comparison.

**Busy waiting (pomale lode) [Busy waiting - slow ships]**  
There is a sleep call inserted between the calls to `CCargoPlanner::Ship` (e.g. 100 ms sleep). If the salesperson/worker threads are not synchronized/blocked properly, CPU time is increased, and the test fails.

**Busy waiting (pomali zakaznici) [Busy waiting - slow customers]**  
The customers delay their answers when queried by `CCustomer::Query` (e.g. 100 ms sleep). Worker threads then do not have anything to do. If worker threads are not synchronized/blocked properly, CPU time increases and the test fails.

**Test rozlozeni zateze [Load balance test]**  
The test environment tries, whether the computation of a single problem engages more than one thread. There is just one ship to process, the ship's capacity is big and the cargo list is long. The testing environment checks that the computation time decreases when the number of worker threads increases. This test is a bonus test. Function `ProgtestSolver` returns invalid results in this test (an empty cargo list is returned). You have to implement the function yourself to pass the test.

**Update 2021-03-06:** your program may forget the cargo that is quoted by the customers, but not loaded. Since no two ship head to the same destination, there is not any use for such cargo.

**Sample data:**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskS&Cou=324&Tgr=2051&Tsk=1683)

 **Reference**

 

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Test algoritmu (sekvencni)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.040 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.946 s (limit: 20.000 s)
        -   CPU time: 1.099 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.224 s (limit: 19.054 s)
        -   CPU time: 0.895 s (limit: 18.901 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=n, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.719 s (limit: 18.830 s)
        -   CPU time: 0.826 s (limit: 18.006 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=1, W=1, C=n)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.712 s (limit: 18.111 s)
        -   CPU time: 0.831 s (limit: 17.180 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=n, W=m, C=k)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.457 s (limit: 17.399 s)
        -   CPU time: 2.463 s (limit: 16.349 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=n, W=m, C=k), prubezna obsluha lo': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.300 s (limit: 16.942 s)
        -   CPU time: 1.593 s (limit: 13.886 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Zakladni test (S=n, W=m, C=k), prubezna obsluha za': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.420 s (limit: 16.642 s)
        -   CPU time: 2.301 s (limit: 12.293 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Test zrychleni vypoctu': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 2.553 s (limit: 16.222 s)
        -   CPU time: 5.691 s (limit: 9.992 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Busy waiting test (pomale lode)': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 3.221 s (limit: 15.000 s)
        -   Optional test success, evaluation: 100.00 %
    -   Test 'Busy waiting test (pomali zakaznici)': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 4.282 s (limit: 11.779 s)
        -   Optional test success, evaluation: 100.00 %
    -   Test 'Rozlozeni zateze': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.213 s (limit: 10.000 s)
        -   CPU time: 0.692 s (limit: 10.000 s)
        -   Bonus test - success, evaluation: 130.00 %
    -   Overall ratio: 130.00 % (= 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.30)
-   Total percent: 130.00 %
-   Early submission bonus: 3.00
-   Total points: 1.30 \* ( 30.00 + 3.00 ) = 42.90

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**21**|--|--|--|
|Lines of code:|**322**|15.33 ± 14.40|58|`CShipment::solveRect`|
|Cyclomatic complexity:|**65**|3.10 ± 3.13|13|`CShipment::SolveTile`|

**5**

**2021-04-04 15:55:24**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskD&Cou=324&Tgr=2051&Tsk=1683&Sub=1275364)

**Submission status:**

Evaluated

 

**Evaluation:**

30.0000

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Algorithm test (sequential)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.150 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.393 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.224 s (limit: 19.607 s)
        -   CPU time: 0.726 s (limit: 19.607 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.343 s (limit: 19.383 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=n)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.249 s (limit: 19.040 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=m, C=k)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.280 s (limit: 18.791 s)
        -   CPU time: 1.209 s (limit: 18.289 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic (S=n, W=m, C=k), continuous ship service': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.306 s (limit: 18.511 s)
        -   CPU time: 1.111 s (limit: 17.080 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic (S=n, W=m, C=k), continuous customer service': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.229 s (limit: 18.205 s)
        -   CPU time: 0.933 s (limit: 15.969 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Speedup test': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 1.176 s (limit: 17.976 s)
        -   CPU time: 2.295 s (limit: 15.036 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Busy waiting test (slow ships)': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 3.229 s (limit: 15.000 s)
        -   Optional test success, evaluation: 100.00 %
    -   Test 'Busy waiting test (slow customers)': success
        -   result: 100.00 %, required: 50.00 %
        -   Total run time: 4.617 s (limit: 11.771 s)
        -   Optional test success, evaluation: 100.00 %
    -   Test 'Load balance': failed
        -   result: 0.00 %, required: 100.00 %
        -   Total run time: 1.743 s (limit: 10.000 s)
        -   Bonus test - failed, evaluation: No bonus awarded
        -   Failed (invalid output)
        -   Failed (invalid output)
        -   Failed (invalid output)
        -   Failed (invalid output)
    -   Overall ratio: 100.00 % (= 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00)
-   Total percent: 100.00 %
-   Total points: 1.00 \* 30.00 = 30.00

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**10**|--|--|--|
|Lines of code:|**131**|13.10 ± 11.19|37|`CCargoPlanner::collect`|
|Cyclomatic complexity:|**30**|3.00 ± 1.61|6|`CCargoPlanner::collect`|

**4**

**2021-04-04 02:03:32**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskD&Cou=324&Tgr=2051&Tsk=1683&Sub=1274855)

**Submission status:**

Evaluated

 

**Evaluation:**

0.0000

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Algorithm test (sequential)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.035 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.414 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.155 s (limit: 19.586 s)
        -   CPU time: 0.503 s (limit: 19.586 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.457 s (limit: 19.431 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=n)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.325 s (limit: 18.974 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=m, C=k)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.310 s (limit: 18.649 s)
        -   CPU time: 1.328 s (limit: 18.301 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic (S=n, W=m, C=k), continuous ship service': Abnormal program termination (Time limit exceeded)
        -   Cumulative test time exceeded, killed after:: 18.368 s (limit: 18.339 s)
        -   Mandatory test failed, evaluation: 0.00 %
    -   Overall ratio: 0.00 % (= 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 0.00)
-   Total percent: 0.00 %
-   Total points: 0.00 \* 30.00 = 0.00

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**8**|--|--|--|
|Lines of code:|**91**|11.38 ± 8.31|27|`CCargoPlanner::collect`|
|Cyclomatic complexity:|**22**|2.75 ± 1.56|5|`CCargoPlanner::collect`|

**3**

**2021-04-04 01:40:44**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskD&Cou=324&Tgr=2051&Tsk=1683&Sub=1274842)

**Submission status:**

Evaluated

 

**Evaluation:**

0.0000

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Algorithm test (sequential)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.203 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.411 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.199 s (limit: 19.589 s)
        -   CPU time: 0.637 s (limit: 19.589 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=1, C=1)': Abnormal program termination (Time limit exceeded)
        -   Cumulative test time exceeded, killed after:: 19.417 s (limit: 19.390 s)
        -   Mandatory test failed, evaluation: 0.00 %
    -   Overall ratio: 0.00 % (= 1.00 \* 1.00 \* 1.00 \* 0.00)
-   Total percent: 0.00 %
-   Total points: 0.00 \* 30.00 = 0.00

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**8**|--|--|--|
|Lines of code:|**104**|13.00 ± 10.26|32|`CCargoPlanner::collect`|
|Cyclomatic complexity:|**22**|2.75 ± 1.56|5|`CCargoPlanner::collect`|

**2**

**2021-04-04 01:26:49**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskD&Cou=324&Tgr=2051&Tsk=1683&Sub=1274827)

**Submission status:**

Evaluated

 

**Evaluation:**

0.0000

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Algorithm test (sequential)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.095 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.385 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.187 s (limit: 19.615 s)
        -   CPU time: 0.599 s (limit: 19.614 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.330 s (limit: 19.428 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=n)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.425 s (limit: 19.098 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=m, C=k)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.236 s (limit: 18.673 s)
        -   CPU time: 1.040 s (limit: 18.259 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic (S=n, W=m, C=k), continuous ship service': Abnormal program termination (Time limit exceeded)
        -   Cumulative test time exceeded, killed after:: 18.452 s (limit: 18.437 s)
        -   Mandatory test failed, evaluation: 0.00 %
    -   Overall ratio: 0.00 % (= 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 1.00 \* 0.00)
-   Total percent: 0.00 %
-   Total points: 0.00 \* 30.00 = 0.00

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**8**|--|--|--|
|Lines of code:|**105**|13.13 ± 10.17|32|`CCargoPlanner::collect`|
|Cyclomatic complexity:|**22**|2.75 ± 1.56|5|`CCargoPlanner::collect`|

**1**

**2021-04-04 01:12:36**

[Download](https://progtest.fit.cvut.cz/index.php?X=TaskD&Cou=324&Tgr=2051&Tsk=1683&Sub=1274813)

**Submission status:**

Evaluated

 

**Evaluation:**

0.0000

-   **Evaluator: computer**
    -   Program compiled
    -   Test 'Algorithm test (sequential)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 1.073 s (limit: 10.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=1, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.443 s (limit: 20.000 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=1, W=n, C=1)': success
        -   result: 100.00 %, required: 100.00 %
        -   Total run time: 0.210 s (limit: 19.557 s)
        -   CPU time: 0.578 s (limit: 19.557 s)
        -   Mandatory test success, evaluation: 100.00 %
    -   Test 'Basic test (S=n, W=1, C=1)': Abnormal program termination (Time limit exceeded)
        -   Cumulative test time exceeded, killed after:: 19.374 s (limit: 19.347 s)
        -   Mandatory test failed, evaluation: 0.00 %
    -   Overall ratio: 0.00 % (= 1.00 \* 1.00 \* 1.00 \* 0.00)
-   Total percent: 0.00 %
-   Total points: 0.00 \* 30.00 = 0.00

**SW metrics:**

||
| |Total|Average|Maximum|Function name|
|Functions:|**8**|--|--|--|
|Lines of code:|**105**|13.13 ± 9.97|32|`CCargoPlanner::collect`|
|Cyclomatic complexity:|**22**|2.75 ± 1.56|5|`CCargoPlanner::collect`|


