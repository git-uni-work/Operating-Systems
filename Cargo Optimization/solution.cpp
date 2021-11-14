#ifndef __PROGTEST__
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <climits>
#include <cfloat>
#include <cassert>
#include <cmath>
#include <iostream>
#include <iomanip>
#include <algorithm>
#include <numeric>
#include <string>
#include <vector>
#include <array>
#include <iterator>
#include <set>
#include <list>
#include <map>
#include <unordered_set>
#include <unordered_map>
#include <queue>
#include <stack>
#include <deque>
#include <memory>
#include <functional>
#include <thread>
#include <mutex>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <pthread.h>
#include <semaphore.h>
#include "progtest_solver.h"
#include "sample_tester.h"
using namespace std;
#endif /* __PROGTEST__ */

class CCargoPlanner
{
  public:

    vector < ACustomer > customers;
    vector < thread > sale;
    vector < thread > worker;
    // map < string, vector< CCargo > > shipments;
    queue < AShip > ships;
    queue <pair< AShip, vector<CCargo> >> loads;
    atomic<int> yadunknow = 0;
    int producers;
    atomic<int> check = 0;
    mutex m1, m2;
    condition_variable empty_bay, empty_ship;

    static int SeqSolver( const vector<CCargo> & cargo, int maxWeight, int maxVolume, vector<CCargo> & load )
    { return ProgtestSolver(cargo, maxWeight, maxVolume, load); }

    bool pred1()
    {
      if( ships.empty() && yadunknow )
      { return true; }
      else
      { return !ships.empty(); }
    }
    // SALES THREAD
    void collect( int id )
    {
      while( !ships.empty() || !yadunknow )
      {
        unique_lock<mutex> locker(m1);
        cout << "SALES " << id << " TRYING..." << endl;
        // conditional variable "wait" - empty queue
        empty_bay.wait( locker, bind(&CCargoPlanner::pred1, this) );
        cout << "SALES " << id << " WORKING..." << endl;
        if( !ships.empty() )
        {
          // pop ship from the queue
          AShip ship = ships.front();
          ships.pop();
          locker.unlock();
          // quote customers for destination of the ship
          vector <CCargo> result;
          for( auto & c : customers )
          {
            vector < CCargo > list;
            c->Quote( ship->Destination(), list );
            if( !list.empty() )
            { result.insert( result.begin(), list.begin(), list.end() ); }
          }
          unique_lock<mutex> locker2(m2);
          // store destination and list of cargo into loads
          loads.push(make_pair(ship, result));
          cout << "SALES " << id << " COLLECTED CARGO FOR " << ship->Destination() << endl;
          locker2.unlock();
          // notify one worker thread
          empty_ship.notify_one();
          locker.lock();
        }
        else
        { break; }
      }
      cout << "!!! SALES " << id << " DONE !!!" << endl;
      unique_lock<mutex> locker(m1);
      producers--;
      // notify one worker thread
      empty_ship.notify_one();
      cout << "NO. OF PRODUCERS = " << producers << endl;
    }

    bool pred2()
    {
      if( loads.empty() && producers == 0 )
      { return true; }
      else
      { return !loads.empty(); }
    }

    // WORKER THREAD
    void solve( int id )
    {
      while( !loads.empty() || producers != 0 )
      {
        unique_lock<mutex> locker2(m2);
        cout << "WORKER " << id << " TRYING..." << endl;
        // conditional variable "wait" - empty queue
        empty_ship.wait( locker2, bind(&CCargoPlanner::pred2, this) );
        cout << "WORKER "<< id << " WORKING..." << endl;
        if( !loads.empty() )
        {
          // pop ship and list of cargo from the queue
          pair< AShip, vector<CCargo> > x = loads.front();
          loads.pop();
          locker2.unlock();
          // call SeqSolver for the list of cargo
          vector <CCargo> result;
          SeqSolver(x.second, x.first->MaxWeight(), x.first->MaxVolume(), result);
          // load the ship with the optimal cargo
          x.first->Load(result);
          cout << "WORKER " << id << " LOADED SHIP GOING TO " << x.first->Destination() << endl;
          // notify one sales thread
          empty_bay.notify_one();
          locker2.lock();
        }
        else
        { break; }
      }
      cout << "!!! WORKER " << id << " DONE !!!" << endl;
    }

    void Start( int sales, int workers )
    {
      producers = sales;
      for( int i = 0 ; i < sales ; i++ )
      { sale.push_back( thread( &CCargoPlanner::collect, this, i ) ); }
      for( int i = 0 ; i < workers ; i++ )
      { worker.push_back( thread( &CCargoPlanner::solve, this, i ) ); }
    }

    void Stop( void )
    {
      unique_lock<mutex> locker(m1);
      yadunknow = 1;
      locker.unlock();
      empty_bay.notify_all();
      for( auto & t : sale )
      { t.join(); }
      empty_ship.notify_all();
      for( auto & t : worker )
      { t.join(); }
    }

    void Customer( ACustomer customer )
    { customers.push_back(customer); }

    void Ship( AShip ship )
    {
      cout << "SHIP GOING TO " << ship->Destination() << endl;
      ships.push(ship);
      empty_bay.notify_one();
    }

};

#ifndef __PROGTEST__
int main( void )
{
  CCargoPlanner  test;
  vector<AShipTest> ships;
  vector<ACustomerTest> customers { make_shared<CCustomerTest>(), make_shared<CCustomerTest>  () };

  ships.push_back( g_TestExtra[0].PrepareTest( "New York", customers ) );
  ships.push_back( g_TestExtra[1].PrepareTest( "Barcelona", customers ) );
  ships.push_back( g_TestExtra[2].PrepareTest( "Kobe", customers ) );
  ships.push_back( g_TestExtra[8].PrepareTest( "Perth", customers ) );
  // add more ships here

  for( auto x : customers )
  { test.Customer( x ); }
  cout << "INIT CUSTOMERS" << endl;

  test.Start( 3, 2 );
  cout << "INIT THREADS" << endl << "INCOMING SHIPS..." << endl;

  for( auto x : ships )
  { test.Ship( x ); }
  cout << "SHIPS REGISTERED !!!" << endl;

  test.Stop();
  cout << "YA DUN KNOW !!!" << endl;

  cout << "================" << endl;
  for( auto x : ships )
  { cout << x->Destination () << ": " << ( x->Validate() ? "YE" : "NAH" ) << endl; }
  cout << "================" << endl;

  return 0;
}
#endif /* __PROGTEST__ */
