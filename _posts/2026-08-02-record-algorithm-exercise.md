---
layout: post
title: "Record Algorithm Exercise"
date: 2026-08-02
categories:
    - Programming
tags:
    - Algorithm
    - Exercise
excerpt: "A record of traditional algorithm exercises."
---

1. **Problem:** Judge a linked list be a circular one or not.

   **Solution:** Use two pointers, one fast and one slow. Move the fast pointer two steps and the slow pointer one step at a time. If they meet, the linked list is circular; if the fast pointer reaches the end, it is not circular.

   **Image example:**
   ![Floyd's cycle detection with fast and slow pointers](../assets/images/2026-08-02-record-algorithm-exercise/image.png)

   **Code example:**
   ```cpp
   struct ListNode {
       int val;
       ListNode *next;
       ListNode(int x) : val(x), next(NULL) {}
    };

    class Solution {
    public:
        bool hasCycle(ListNode *head) {
            if (head==nullptr or head->next==nullptr){
                return false;
            }
            ListNode *slow = head;
            ListNode *fast = head->next;
            while(fast!=slow){
                if(fast==nullptr or fast->next==nullptr){
                    return false;
                }
                slow=slow->next;
                fast=fast->next->next;
            }
            return true;
        }    
    }
   ```

   **Time complexity:** O(n), where n is the number of nodes in the linked list.

   **Points:** if a linked list is circular, the fast pointer will eventually meet the slow pointer just like a running competition. If it is not circular, the fast pointer will reach the end of the list (null) before meeting the slow pointer.

2. **Problem:** Merge two linked list into one.

   **Solution:** Use a new begin node and then traverse both linked lists, comparing the values of the current nodes. Append the smaller value to the new list and move the pointer of that list forward. Continue until one of the lists is exhausted, then append the remaining nodes from the other list.

   **Code example:**
   ```cpp
    struct ListNode {
        int val;
        ListNode *next;
        ListNode(int x) : val(x), next(NULL) {}
    };

    class Solution {
    public:
        ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
            ListNode* dummy = new ListNode();
            ListNode* current = dummy;
            while(list1 != nullptr and list2 != nullptr){
                if(list1->val < list2->val){
                    current->next = list1;
                    list1 = list1->next;
                }
                else{
                    current->next = list2;
                    list2 = list2->next;
                }
                current = current->next;
            }
            if(list1 != nullptr){
                current->next = list1;
            }
            else{
                current->next = list2;
            }

            return dummy->next;
        }
    };
   ```

   **Time complexity:** O(n), where n is the total number of nodes in both linked lists.

   **Points:** Just traverse both linked lists once and compare their values to merge them in sorted order.

3. **Problem:** Use linked lists to store large numbers, try to add them.

   **Solution:** Traverse both linked lists simultaneously, adding corresponding digits along with any carry from the previous addition. Create a new linked list to store the result.

   **Code example:**
   ```cpp
   struct ListNode {
     int val;
     ListNode *next;
     ListNode() : val(0), next(nullptr) {}
     ListNode(int x) : val(x), next(nullptr) {}
     ListNode(int x, ListNode *next) : val(x), next(next) {}
   };

   class Solution {
    public:
        ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
            ListNode * dummy = new ListNode();
            ListNode * current = dummy;
            int x = 0;

            while(l1 != nullptr or l2 != nullptr or x!=0){
                if(l1!=nullptr){
                    x += l1->val;
                    l1 = l1->next;
                }
                if(l2!=nullptr){
                    x += l2->val;
                    l2 = l2->next;
                }
                current->next = new ListNode(x%10);
                current = current->next;
                x /= 10;
            }
            return dummy->next;
        }
    };
   ```

   **Time complexity:** O(n), where n is the total number of nodes in both linked lists.

   **Points:** A carry is maintained during the addition process, and the result is stored in a new linked list.

4. **Problem:** Delete the last No.n node from a linked list.

   **Solution:** Use two pointers, one fast and one slow. Move the fast pointer n steps ahead, then move both pointers until the fast pointer reaches the end. The slow pointer will then point to the node to be deleted.

   **Code example:**
   ```cpp
    struct ListNode {
         int val;
         ListNode *next;
         ListNode(int x) : val(x), next(NULL) {}
     };
    
     class Solution {
     public:
          ListNode* removeNthFromEnd(ListNode* head, int n) {
                ListNode * dummy = new ListNode(0);
                dummy->next = head;
                ListNode * fast = dummy;
                ListNode * slow = dummy;
    
                for(int i=0; i<n+1; i++){
                 fast = fast->next;
                }
                while(fast!=nullptr){
                 fast = fast->next;
                 slow = slow->next;
                }
                slow->next = slow->next->next;
    
                return dummy->next;
          }
     };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the linked list.

   **Points:** Let the fast pointer move n+1 steps ahead, then move both pointers until the fast pointer reaches the end. The slow pointer will then point to the node to be deleted.

5. **Problem:** Exchange nodes two by two in a linked list.

   **Solution:** Serveral times of pointers exchange, we can exchange the nodes two by two in a linked list.

   **Code example:**
   ```cpp
    struct ListNode {
         int val;
         ListNode *next;
         ListNode(int x) : val(x), next(NULL) {}
     };
    
     class Solution {
    public:
        ListNode* swapPairs(ListNode* head) {
            if (head==nullptr){
                return nullptr;
            }
            if (head->next==nullptr){
                return head;
            }

            ListNode* prev = new ListNode();
            ListNode* temp = prev;
            temp->next = head;

            while(temp->next!=nullptr and temp->next->next!=nullptr){
                ListNode* node1 = temp->next;
                ListNode* node2 = temp->next->next;
                temp->next = node2;
                node1->next = node2->next;
                node2->next = node1;
                temp = node1;
            }

            return prev->next;
        }
    };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the linked list.

   **Points:** Four nodes are involved in the swapping process: the previous node, the first node to be swapped, the second node to be swapped, and the next node after the second node.

6. **Problem:** Deep copy a linked list with random pointers.

   **Solution:** Use a hash map to store the mapping between original nodes and their copies. First, create all the new nodes and store them in the hash map. Then, iterate through the original list again to set the next and random pointers of the new nodes based on the hash map.

   **Image example:**
   ![Deep copy a linked list with random pointers](../assets/images/2026-08-02-record-algorithm-exercise/image-1.png)

   **Code example:**
   ```cpp
    struct Node {
         int val;
         Node* next;
         Node* random;
         Node(int _val) {
              val = _val;
              next = NULL;
              random = NULL;
         }
    };

    class Solution {
    public:
        Node* copyRandomList(Node* head) {
            unordered_map<Node*, Node*> hmap;

            Node*current = head;
            while(current!=nullptr){
                hmap[current] = new Node(current->val);
                current = current->next;
            }

            current = head;
            while(current!=nullptr){
                hmap[current]->next = hmap[current->next];
                hmap[current]->random = hmap[current->random];
                current = current->next;
            }

            return hmap[head];
        }
    };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the linked list.

   **Points:** The key is to use a hash map to store the mapping between original nodes and their copies, and then set the next and random pointers of the new nodes based on the hash map.

7. **Problem:** Calculate the depth of a binary tree.

   **Solution:** Do a depth-first search (DFS) or breadth-first search (BFS) to traverse the tree and keep track of the maximum depth encountered.

   **Image example:**
   ![binary tree](../assets/images/2026-08-02-record-algorithm-exercise/image-2.png)

   **Code example:**
   ```cpp
    struct TreeNode {
         int val;
         TreeNode *left;
         TreeNode *right;
         TreeNode(int x) : val(x), left(NULL), right(NULL) {}
     };

     class Solution {
     public:
         int maxDepth(TreeNode* root) {
             if(root==nullptr){
                 return 0;
             }
             return 1 + max(maxDepth(root->left), maxDepth(root->right));
         }
     };

     class Solution1 {
     public:
         int maxDepth(TreeNode* root) {
             if(root==nullptr){
                 return 0;
             }
             queue<TreeNode*> q;
             q.push(root);
             int depth = 0;
             while(!q.empty()){
                 int size = q.size();
                 while(size!=0){
                     TreeNode* node = q.front();
                     q.pop();
                     if(node->left!=nullptr){
                         q.push(node->left);
                     }
                     if(node->right!=nullptr){
                         q.push(node->right);
                     }
                     size--;
                 }
                 depth++;
             }
             return depth;
         }
     };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the binary tree.

   **Points:** The key is to use a recursive approach to traverse the tree and keep track of the maximum depth encountered.

8. **Problem:** Invert a binary tree.

   **Solution:** Use a recursive approach to traverse the tree. For each node, swap its left and right children, then recursively invert the left and right subtrees.

   **Image example:**
   ![Invert a binary tree](../assets/images/2026-08-02-record-algorithm-exercise/image-3.png)

   **Code example:**
   ```cpp
    struct TreeNode {
         int val;
         TreeNode *left;
         TreeNode *right;
         TreeNode(int x) : val(x), left(NULL), right(NULL) {}
     };

     class Solution {
     public:
         TreeNode* invertTree(TreeNode* root) {
             if(root==nullptr){
                 return nullptr;
             }
             else{
                TreeNode* left = invertTree(root->left);
                TreeNode* right = invertTree(root->right);
                root->left = right;
                root->right = left;
             }
             return root;
         }
     };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the binary tree.

   **Points:** The key is to use a recursive approach to traverse the tree and swap the left and right children of each node.

9. **Problem:** Judge if a binary tree is a symmetric binary tree.

   **Solution:** Judge left->right and right->left are equal or not and left->left and right->right are equal or not. If they are equal, the binary tree is symmetric; otherwise, it is not.

   **Image example:**
   ![Judge a binary is symmetric or not](../assets/images/2026-08-02-record-algorithm-exercise/image-4.png)

   **Code example:**
   ```cpp
    struct TreeNode {
         int val;
         TreeNode *left;
         TreeNode *right;
         TreeNode(int x) : val(x), left(NULL), right(NULL) {}
     };

     class Solution {
     public:
         bool isSymmetric(TreeNode* root) {
             if(root==nullptr){
                 return true;
             }
             return isMirror(root->left, root->right);
         }

         bool isMirror(TreeNode* left, TreeNode* right){
             if(left==nullptr and right==nullptr){
                 return true;
             }
             if(left==nullptr or right==nullptr){
                 return false;
             }
             return (left->val==right->val) and isMirror(left->left, right->right) and isMirror(left->right, right->left);
         }
     };
   ```

   **Time complexity:** O(n), where n is the number of nodes in the binary tree.

   **Points:** The key is to use a recursive approach to traverse the tree and check if the left and right subtrees are mirrors of each other.

10. **Problem:** Make a sorted array into a balanced binary search tree.

    **Solution:** Use a recursive approach to build the tree. Select the middle element of the array as the root, and recursively build the left and right subtrees from the elements before and after the middle element.

    **Code example:**
    ```cpp
       struct TreeNode {
             int val;
             TreeNode *left;
             TreeNode *right;
             TreeNode(int x) : val(x), left(NULL), right(NULL) {}
         };

        class Solution {
        public:
            TreeNode* sortedArrayToBST(vector<int>& nums) {
                if(nums.empty()){
                    return nullptr;
                }
                return buildBST(nums, 0, nums.size()-1);
            }

        private:
            TreeNode* buildBST(vector<int>& nums, int start, int end) {
                if(start>end){
                    return nullptr;
                }
                int mid = start + (end - start) / 2;
                TreeNode* root = new TreeNode(nums[mid]);
                root->left = buildBST(nums, start, mid-1);
                root->right = buildBST(nums, mid+1, end);
                return root;
            }
        };
    ```

    **Time complexity:** O(n), where n is the number of elements in the array.

    **Points:** The key is to use a recursive approach to build the tree by selecting the middle element of the array as the root and recursively building the left and right subtrees.

11. **Problem:** Find the kth smallest element in a binary search tree.

    **Solution:** Use an in-order traversal to visit the nodes in ascending order. Keep a count of the visited nodes and return the k th node.

    **Code example:**
    ```cpp
        struct TreeNode {
             int val;
             TreeNode *left;
             TreeNode *right;
             TreeNode(int x) : val(x), left(NULL), right(NULL) {}
         };

         class Solution {
         public:
             int kthSmallest(TreeNode* root, int k) {
                 int count = 0;
                 int result = 0;
                 inorder(root, k, count, result);
                 return result;
             }

         private:
             void inorder(TreeNode* node, int k, int& count, int& result) {
                 if(node==nullptr){
                     return;
                 }
                 inorder(node->left, k, count, result);
                 count++;
                 if(count==k){
                     result = node->val;
                     return;
                 }
                 inorder(node->right, k, count, result);
             }
         };
    ```

    **Time complexity:** O(n), where n is the number of nodes in the binary tree.

    **Points:** The key is to use a recursive approach to traverse the tree and find the kth smallest element by performing an in-order traversal.

12. **Problem:** Make a binary tree into a linked list.

    **Solution:** use preorder traversal to visit the nodes in the tree and link them together in a linked list.

    **Code example:**
    ```cpp
        struct TreeNode {
             int val;
             TreeNode *left;
             TreeNode *right;
             TreeNode(int x) : val(x), left(NULL), right(NULL) {}
         };

         class Solution {
         public:
            void preorder(TreeNode*node, vector<int>& result){
                if(node==nullptr){
                    return;
                }

                result.push_back(node->val);
                preorder(node->left, result);
                preorder(node->right, result);
            }

            void flatten(TreeNode* root) {
                vector<int> result;
                preorder(root, result);
                TreeNode* current = root;
                for(int i=1; i<result.size(); i++){
                    current->left = nullptr;
                    current->right = new TreeNode(result[i]);
                    current = current->right;
                }
            }
         };
    ```

    **Time complexity:** O(n), where n is the number of nodes in the binary tree.

    **Space complexity:** O(n), where n is the number of nodes in the binary tree.

    **Points:** The key is to use a recursive approach to traverse the tree and convert it into a linked list by performing a preorder traversal.

13. **Problem:** Calculate the total number of islands in a 2D grid.

    **Solution:** Use DFS (Depth-First Search) to traverse the grid. When encountering a '1' (land), initiate a DFS to mark all connected '1's as visited, incrementing the island count.

    **Code example:**
    ```cpp
        class Solution {
        public:
            void dfs(int i, int j, vector<vector<char>>& grid) {
                grid[i][j] = '0'; // Mark the cell as visited
                int rows = grid.size();
                int columns = grid[0].size();
                if (i-1 >= 0 && grid[i-1][j] == '1') dfs(i-1, j, grid); // Up
                if (i+1 < rows && grid[i+1][j] == '1') dfs(i+1, j, grid); // Down
                if (j-1 >= 0 && grid[i][j-1] == '1') dfs(i, j-1, grid); // Left
                if (j+1 < columns && grid[i][j+1] == '1') dfs(i, j+1, grid); // Right
            }

            int numIslands(vector<vector<char>>& grid) {
                int rows = grid.size();
                int columns = grid[0].size();
                int count = 0;
                for(int i=0;i<rows;i++){
                    for(int j=0;j<columns;j++){
                        if(grid[i][j]=='1'){
                            count++;
                            dfs(i,j,grid);
                        }
                    }
                }
            }
        };
    ```

    **Time complexity:** O(m*n), where m is the number of rows and n is the number of columns in the grid.

    **Points:** The key is to use a recursive approach to traverse the grid and mark all connected '1's as visited.

14. **Problem:** Bad orange.

    **Solution:** BFS to make the bad oranges rot all the good oranges.

    **Code example:**
    ```cpp
    class Solution {
    public:
        int orangesRotting(vector<vector<int>>& grid) {
            int rows=grid.size();
            int columns=grid[0].size();
            int freecount=0;

            queue<pair<int, int>> q;

            for(int i=0;i<rows;i++){
                for(int j=0;j<columns;j++){
                    if(grid[i][j]==1){
                        freecount++;
                    }
                    else if(grid[i][j]==2){
                        q.push({i,j});
                    }
                }
            }

            int minutes=0;

            while(!q.empty()){
                if(freecount==0){
                    return minutes;
                }

                int size=q.size();
                minutes++;

                for(int i=0;i<size;i++){
                    auto [x,y] = q.front();
                    q.pop();

                    freecount -= rot(grid,x-1,y,q);
                    freecount -= rot(grid,x+1,y,q);
                    freecount -= rot(grid,x,y-1,q);
                    freecount -= rot(grid,x,y+1,q);
                }
            }

            return freecount>0 ? -1 : minutes;
        }

        int rot(vector<vector<int>>&grid,int x,int y,queue<pair<int,int>>&q){
            int rows=grid.size();
            int columns=grid[0].size();

            if(x<0 or x>=rows or y<0 or y>=columns or grid[x][y]!=1){
                return 0;
            }

            grid[x][y]=2;
            q.push({x,y});

            return 1;
        }
    };
    ```

    **Time complexity:** O(m*n), where m is the number of rows and n is the number of columns in the grid.

    **Points:** The key is to use a breadth-first search approach to simulate the rotting process, ensuring all adjacent good oranges become bad in each time step.

15. **Problem:** The table of class.

    **Solution:** The ready of each class is its indegree and only the classes with zero indegree can be taken, when a class is taken, its neighbors' indegrees are reduced, the algorithm is like BFS.

    **Image example:**
    ![The Image example of graph](../assets/images/2026-08-02-record-algorithm-exercise/image-5.png)

    **Code example:**
    ```cpp
    class Solution {
    public: 
        bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
            vector<int> indeg(numCourses, 0);
            vector<vector<int>> edge(numCourses, vector<int>());

            for(auto& p: prerequisites){
                indeg[p[0]]++;
                edge[p[1]].push_back(p[0]);
            }

            queue<int> q;
            int count = 0;

            for(int i=0;i<numCourses;i++){
                if(indeg[i]==0){
                    q.push(i);
                    count++;
                }
            }

            while(!q.empty()){
                int course = q.front();
                q.pop();

                for(int neighbor: edge[course]){
                    indeg[neighbor]--;
                    if(indeg[neighbor]==0){
                        q.push(neighbor);
                        count++;
                    }
                }
            }

            return count==numCourses;
        }
    };
    ```

    **Time complexity:** O(numCourses + prerequisites.size()).

    **Points:** The key is to use a topological sort approach to determine if all courses can be completed, ensuring no circular dependencies exist.

16. **Problem:** Binary Search.

    **Solution:** Use binary search to find the first occurrence of the target value or its insertion point in a sorted array.

    **Code example:**
    ```cpp
    class Solution {
    public:
        int searchInsert(vector<int>& nums, int target) {
            int left = 0;
            int right = nums.size() - 1;

            while(left <= right) {
                int mid = left + (right - left) / 2;
                if (nums[mid] >= target) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            }
            return left;
        }
    };
    ```

    **Time complexity:** O(log n), where n is the number of elements in the sorted array.

    **Points:** The key is to use a binary search approach to efficiently find the insertion point or the target value in a sorted array.

17. **Problem:** Search the first and the last location of the target in a sorted array.

    **Solution:** Use binary search to find the first and last occurrences of the target value.

    **Code example:**
    ```cpp
    class Solution {
    public:
        vector<int> searchRange(vector<int>& nums, int target) {
            int left = 0;
            int right = nums.size() - 1;
            int first = -1;
            int last = -1;

            // Find first occurrence
            while(left <= right) {
                int mid = left + (right - left) / 2;
                if (nums[mid] > target) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
                if (nums[mid] == target) {
                    first = mid;
                    right = mid - 1; // Continue searching in the left half
                }
            }

            // Find last occurrence
            left = 0;
            right = nums.size() - 1;
            while(left <= right) {
                int mid = left + (right - left) / 2;
                if (nums[mid] < target) {
                    left = mid + 1;
                } else {
                    right = mid - 1;
                }
                if (nums[mid] == target) {
                    last = mid;
                    left = mid + 1; // Continue searching in the right half
                }
            }

            vector<int> result;
            result.push_back(first);
            result.push_back(last);
            return result;
        }
    };
    ```

    **Time complexity:** O(log n), where n is the number of elements in the array.

    **Points:** The key is to use binary search twice to find the first and last occurrences of the target value.

18. **Problem:** search rotating array.

    **Solution:** First fing the place where the array is rotated, then use binary search.

    **Code example:**
    ```cpp
    class Solution {
    public:
        int search(vector<int>& nums, int target) {
            if(!nums.size()){
                return -1;
            }

            if(nums.size()==1){
                return nums[0]==target ? 0 : -1;
            }
            
            int left = 1;
            int right = nums.size() - 1;
            int temptarget=nums[0];

            // Find the rotation point
            while(left <= right) {
                int mid = left + (right - left) / 2;
                if (nums[mid] <= temptarget) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            }

            if (target >= temptarget) {
                left = 0;
            } 
            else {
                right = nums.size() - 1;
            }

            // Perform binary search in the appropriate half
            while(left <= right) {
                int mid = left + (right - left) / 2;
                if (nums[mid] == target) {
                    return mid;
                } 
                else if (nums[mid] < target) {
                    left = mid + 1;
                } 
                else {    
                    right = mid - 1;
                }
            }

            return -1;
        }
    };
    ```

    **Time complexity:** O(log n), where n is the number of elements in the array.

    **Points:** The key is to use binary search to efficiently find the target value in a sorted array, first finding the rotation point and then performing a standard binary search in the appropriate half, paying attention to the boundaries and the actions taken at each step.

19. **Problem:** Effective brackets.

    **Solution:** Use a stack to keep track of the opening brackets and ensure that each closing bracket matches the most recent opening bracket.

    **Code example:**
    ```cpp
    class Solution {
    public:
        bool isValid(string s) {
            stack<char> st;
            for(char c : s) {
                if(c == '(' or c == '{' or c == '[') {
                    st.push(c);
                } 
                else {
                    if(st.empty()) {
                        return false;
                    }
                    char top = st.top();
                    st.pop();
                    if(c == ')' and top != '('){
                        return false;
                    }
                    if(c == '}' and top != '{'){
                        return false;
                    }
                    if(c == ']' and top != '['){
                        return false;
                    }
                }
            }
            return st.empty() ? true : false;
        }
    };
    ```

    **Time complexity:** O(n), where n is the length of the string.

    **Points:** The key is to use a stack to match opening and closing brackets, ensuring that each closing bracket corresponds to the most recent opening bracket.

20. **Problem:** Decode the string.

    **Solution:** Use a stack to store the position of the elements and the times it will be repeated.

    **Code example:**
    ```cpp
    class Solution {
    public:
        string decodeString(string s) {
            stack<pair<int, int>> st;
            string ans;
            int count = 0;
            for(auto ch:s){
                if(isdigit(ch)){
                    count = count*10 + (ch-'0');
                }
                else if(isalpha(ch)){
                    ans += ch;
                }
                else if(ch=='['){
                    st.push({ans.size(), count});
                    count = 0;
                }
                else if(ch==']'){
                    auto [pos, times] = st.top();
                    st.pop();
                    string temp = ans.substr(pos, ans.size()-pos);
                    for(int i=0;i<times-1;i++){
                        ans += temp;
                    }
                }
            }
            return ans;
        }
    };
    ```

    **Time complexity:** O(n), where n is the length of the input string.

    **Points:** The key is to use a stack to store the position and repetition count of each opening bracket, allowing for efficient string reconstruction when closing brackets are encountered.

21. **Problem:** Daily temperatures
    
    **Solution:** Use a stack to keep track of the indices of the temperatures. For each temperature, pop from the stack until the current temperature is less than or equal to the temperature at the index stored in the stack. The difference in indices gives the number of days until a warmer temperature.

    **Code example:**
    ```cpp
    class Solution {
    public:
        vector<int> dailyTemperatures(vector<int>& temperatures) {
            int n = temperatures.size();
            vector<int> result(n, 0);
            stack<int> st; // Store indices of temperatures         

            for(int i=0; i<n; i++) {
                while(!st.empty() and temperatures[i] > temperatures[st.top()]) {
                    int prev = st.top();
                    st.pop();
                    result[prev] = i - prev;
                }
                st.push(i);
            }

            return result;
        }
    };
    ``` 
    **Time complexity:** O(n), where n is the number of temperatures.

    **Points:** The key is to use a stack to efficiently track the indices of temperatures, allowing for quick determination of the number of days until a warmer temperature is encountered.

22. **Problem:** Quick_select Problem.

    **Solution:** Use quick_sort algorithm and judge the right position of the target element k.

    **Code example:**
    ```cpp
    class Solution {
    public:
        int quick_select(vector<int>& nums, int left, int right, int k) {
            if (left == right) {
                return nums[left];
            }

            int i=left, j=right;
            int pivot = nums[left + (right - left) / 2];
            while (i <= j) {
                while (nums[i] < pivot) i++;
                while (nums[j] > pivot) j--;
                if (i <= j) {
                    swap(nums[i], nums[j]);
                    i++;
                    j--;
                }
            }

            if (k <= j) {
                return quick_select(nums, left, j, k);
            }
            if (k >= i) {
                return quick_select(nums, i, right, k);
            }

            return nums[k];
        }

        int findKthLargest(vector<int>& nums, int k) {
            int n = nums.size();
            return quick_select(nums, 0, n - 1, n - k);
        }
    };
    ```

    **Time complexity:** O(n) average, O(n^2) worst case.

    **Points:** The key is to use the quick select algorithm to efficiently find the kth largest element without fully sorting the array.

23. **Problem:** Find the most k frequent elements.

    **Solution:** Use a hash map to count the frequency of each element, then use a max-heap to keep track of the k most frequent elements.

    **Code example:**
    ```cpp
    class Solution {
    public:
        vector<int> topKFrequent(vector<int>& nums, int k) {
            unordered_map<int, int> freqMap;
            for(int num : nums) {
                freqMap[num]++;
            }

            priority_queue<pair<int, int>> maxHeap;
            for(auto& entry : freqMap) {
                maxHeap.push({entry.second, entry.first});
            }

            vector<int> result;
            for(int i = 0; i < k; i++) {
                result.push_back(maxHeap.top().second);
                maxHeap.pop();
            }

            return result;
        }
    };
    ```

    **Time complexity:** O(n log n), where n is the number of elements in the array.

    **Points:** The key is to use a hash map to count the frequency of each element and a max-heap to efficiently retrieve the k most frequent elements.

24. **Problem:** Find the best time to buy stock.

    **Solution:** Use the algorithm of greedy to find the maximum profit.

    **Code example:**
    ```cpp
    class Solution {
    public:
        int maxProfit(vector<int>& prices) {
            if(!prices.size()){
                return 0;
            }

            int minPrice = prices[0];
            int maxProfit = 0;

            for(int price : prices) {
                minPrice = min(minPrice, price);
                maxProfit = max(maxProfit, price - minPrice);
            }

            return maxProfit;
        }
    };
    ```

    **Time complexity:** O(n), where n is the number of elements in the array.

    **Points:** The key is to use a greedy approach to track the minimum price seen so far and calculate the maximum profit by comparing the current price with the minimum price.

25. **Problem:** Jump game.

    **Solution:** Use the algorithm of greedy to find the longest position it can reach.

    **Code example:**
    ```cpp
    class Solution {
    public:
        bool canJump(vector<int>& nums) {
            int maxReach = 0;
            
            for(int i = 0; i < nums.size(); i++){
                if(i <= maxReach){
                    maxReach = max(maxReach, i + nums[i]);
                    if (maxReach >= nums.size() - 1) {
                        return true;
                    }
                }
            }
           
            return false;
        }
    };
    ```

    **Time complexity:** O(n), where n is the number of elements in the array.

    **Points:** The key is to use a greedy approach to track the maximum position that can be reached, updating it as we iterate through the array, paying attention to whether the current position is reachable.
