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

   