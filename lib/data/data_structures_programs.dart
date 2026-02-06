/// Data Structures for C Programming - 10 Topic-wise Programs
/// Each program includes explanation, code, and complexity analysis

class DSProgram {
  final String id;
  final String title;
  final String topic;
  final String description;
  final String explanation;
  final String code;
  final String timeComplexity;
  final String spaceComplexity;
  final List<String> keyPoints;
  final String iconName;
  final int colorValue;

  const DSProgram({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.explanation,
    required this.code,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.keyPoints,
    required this.iconName,
    required this.colorValue,
  });
}

const List<DSProgram> dataStructuresPrograms = [
  // 1. Arrays
  DSProgram(
    id: 'arrays',
    title: 'Array Operations',
    topic: 'Arrays',
    description: 'Basic array operations - insertion, deletion, traversal',
    explanation: '''
Arrays are the simplest data structure that stores elements of the same type in contiguous memory locations.

**Key Concepts:**
• Fixed size determined at compile time
• Elements accessed using index (0-based)
• Contiguous memory allocation
• Random access in O(1) time

**Memory Layout:**
arr[0] → [10] ← Base Address
arr[1] → [20] ← Base + 4 bytes
arr[2] → [30] ← Base + 8 bytes

**When to use:**
- When you know the size in advance
- Need fast random access
- Elements are of same type
''',
    code: '''#include <stdio.h>

#define MAX_SIZE 100

// Function to insert element at position
void insertAt(int arr[], int *n, int pos, int value) {
    if (*n >= MAX_SIZE) {
        printf("Array is full!\\n");
        return;
    }
    
    // Shift elements to right
    for (int i = *n; i > pos; i--) {
        arr[i] = arr[i - 1];
    }
    
    arr[pos] = value;
    (*n)++;
    printf("Inserted %d at position %d\\n", value, pos);
}

// Function to delete element at position
void deleteAt(int arr[], int *n, int pos) {
    if (pos < 0 || pos >= *n) {
        printf("Invalid position!\\n");
        return;
    }
    
    int deleted = arr[pos];
    
    // Shift elements to left
    for (int i = pos; i < *n - 1; i++) {
        arr[i] = arr[i + 1];
    }
    
    (*n)--;
    printf("Deleted %d from position %d\\n", deleted, pos);
}

// Function to display array
void display(int arr[], int n) {
    printf("Array: ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

// Function to search element
int search(int arr[], int n, int key) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == key) {
            return i;  // Found at index i
        }
    }
    return -1;  // Not found
}

int main() {
    int arr[MAX_SIZE] = {10, 20, 30, 40, 50};
    int n = 5;
    
    printf("Initial ");
    display(arr, n);
    
    // Insert 25 at position 2
    insertAt(arr, &n, 2, 25);
    display(arr, n);
    
    // Delete element at position 4
    deleteAt(arr, &n, 4);
    display(arr, n);
    
    // Search for 30
    int pos = search(arr, n, 30);
    if (pos != -1) {
        printf("Element 30 found at index %d\\n", pos);
    }
    
    return 0;
}''',
    timeComplexity: 'Access: O(1), Search: O(n), Insert: O(n), Delete: O(n)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Elements stored in contiguous memory',
      'Fixed size at compile time',
      'O(1) random access using index',
      'Insertion/deletion requires shifting',
    ],
    iconName: 'grid_view',
    colorValue: 0xFFFF6B6B,
  ),

  // 2. Linked Lists
  DSProgram(
    id: 'linked_list',
    title: 'Singly Linked List',
    topic: 'Linked Lists',
    description: 'Complete linked list implementation with all operations',
    explanation: '''
A Linked List is a linear data structure where elements are stored in nodes, and each node points to the next node.

**Structure:**
[Data|Next] → [Data|Next] → [Data|NULL]
   Head          Node         Tail

**Advantages over Arrays:**
• Dynamic size - grows as needed
• Efficient insertion/deletion at beginning: O(1)
• No memory wastage

**Disadvantages:**
• No random access - must traverse
• Extra memory for pointers
• Not cache-friendly

**Types:**
1. Singly Linked List
2. Doubly Linked List
3. Circular Linked List
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Node structure
struct Node {
    int data;
    struct Node* next;
};

// Create a new node
struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

// Insert at beginning - O(1)
void insertAtBeginning(struct Node** head, int data) {
    struct Node* newNode = createNode(data);
    newNode->next = *head;
    *head = newNode;
    printf("Inserted %d at beginning\\n", data);
}

// Insert at end - O(n)
void insertAtEnd(struct Node** head, int data) {
    struct Node* newNode = createNode(data);
    
    if (*head == NULL) {
        *head = newNode;
        return;
    }
    
    struct Node* temp = *head;
    while (temp->next != NULL) {
        temp = temp->next;
    }
    temp->next = newNode;
    printf("Inserted %d at end\\n", data);
}

// Delete by value
void deleteNode(struct Node** head, int key) {
    struct Node* temp = *head;
    struct Node* prev = NULL;
    
    // If head node holds the key
    if (temp != NULL && temp->data == key) {
        *head = temp->next;
        free(temp);
        printf("Deleted %d\\n", key);
        return;
    }
    
    // Search for key
    while (temp != NULL && temp->data != key) {
        prev = temp;
        temp = temp->next;
    }
    
    if (temp == NULL) {
        printf("Key %d not found\\n", key);
        return;
    }
    
    prev->next = temp->next;
    free(temp);
    printf("Deleted %d\\n", key);
}

// Display linked list
void display(struct Node* head) {
    printf("List: ");
    while (head != NULL) {
        printf("%d -> ", head->data);
        head = head->next;
    }
    printf("NULL\\n");
}

// Count nodes
int countNodes(struct Node* head) {
    int count = 0;
    while (head != NULL) {
        count++;
        head = head->next;
    }
    return count;
}

int main() {
    struct Node* head = NULL;
    
    insertAtEnd(&head, 10);
    insertAtEnd(&head, 20);
    insertAtEnd(&head, 30);
    insertAtBeginning(&head, 5);
    
    display(head);
    printf("Total nodes: %d\\n", countNodes(head));
    
    deleteNode(&head, 20);
    display(head);
    
    return 0;
}''',
    timeComplexity: 'Access: O(n), Search: O(n), Insert at head: O(1), Delete: O(n)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Dynamic size allocation',
      'No contiguous memory required',
      'O(1) insertion at beginning',
      'Must traverse for random access',
    ],
    iconName: 'link',
    colorValue: 0xFF4ECDC4,
  ),

  // 3. Stacks
  DSProgram(
    id: 'stack',
    title: 'Stack Implementation',
    topic: 'Stacks',
    description: 'LIFO data structure using arrays',
    explanation: '''
A Stack is a linear data structure that follows LIFO (Last In First Out) principle.

**Visual Representation:**
     ┌───┐
     │ 30│ ← Top (Last In, First Out)
     ├───┤
     │ 20│
     ├───┤
     │ 10│ ← Bottom (First In)
     └───┘

**Operations:**
• Push: Add element to top - O(1)
• Pop: Remove element from top - O(1)
• Peek: View top element - O(1)
• isEmpty: Check if stack is empty

**Real-world uses:**
1. Undo/Redo operations
2. Browser back button
3. Function call stack
4. Expression evaluation
5. Balanced parentheses check
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX_SIZE 100

// Stack structure
struct Stack {
    int items[MAX_SIZE];
    int top;
};

// Initialize stack
void initialize(struct Stack* s) {
    s->top = -1;
}

// Check if stack is full
bool isFull(struct Stack* s) {
    return s->top == MAX_SIZE - 1;
}

// Check if stack is empty
bool isEmpty(struct Stack* s) {
    return s->top == -1;
}

// Push operation - O(1)
void push(struct Stack* s, int value) {
    if (isFull(s)) {
        printf("Stack Overflow! Cannot push %d\\n", value);
        return;
    }
    s->items[++s->top] = value;
    printf("Pushed: %d\\n", value);
}

// Pop operation - O(1)
int pop(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack Underflow!\\n");
        return -1;
    }
    int popped = s->items[s->top--];
    printf("Popped: %d\\n", popped);
    return popped;
}

// Peek operation - O(1)
int peek(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\\n");
        return -1;
    }
    return s->items[s->top];
}

// Display stack
void display(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\\n");
        return;
    }
    
    printf("Stack (top to bottom): ");
    for (int i = s->top; i >= 0; i--) {
        printf("%d ", s->items[i]);
    }
    printf("\\n");
}

// Get size of stack
int size(struct Stack* s) {
    return s->top + 1;
}

int main() {
    struct Stack stack;
    initialize(&stack);
    
    push(&stack, 10);
    push(&stack, 20);
    push(&stack, 30);
    
    display(&stack);
    printf("Top element: %d\\n", peek(&stack));
    printf("Stack size: %d\\n", size(&stack));
    
    pop(&stack);
    display(&stack);
    
    return 0;
}''',
    timeComplexity: 'Push: O(1), Pop: O(1), Peek: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'LIFO - Last In First Out',
      'All operations are O(1)',
      'Used in recursion and backtracking',
      'Can be implemented using arrays or linked lists',
    ],
    iconName: 'layers',
    colorValue: 0xFFFFB347,
  ),

  // 4. Queues
  DSProgram(
    id: 'queue',
    title: 'Queue Implementation',
    topic: 'Queues',
    description: 'FIFO data structure with circular queue',
    explanation: '''
A Queue is a linear data structure that follows FIFO (First In First Out) principle.

**Visual Representation:**
Front →  [10] [20] [30] [40]  ← Rear
         ↑                    ↑
      Dequeue              Enqueue

**Operations:**
• Enqueue: Add element at rear - O(1)
• Dequeue: Remove element from front - O(1)
• Front: View front element - O(1)
• isEmpty: Check if queue is empty

**Types:**
1. Simple Queue
2. Circular Queue
3. Priority Queue
4. Double-ended Queue (Deque)

**Real-world uses:**
1. Printer job scheduling
2. CPU task scheduling
3. BFS traversal
4. Call center systems
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX_SIZE 5

// Circular Queue structure
struct Queue {
    int items[MAX_SIZE];
    int front;
    int rear;
    int count;
};

// Initialize queue
void initialize(struct Queue* q) {
    q->front = 0;
    q->rear = -1;
    q->count = 0;
}

// Check if queue is full
bool isFull(struct Queue* q) {
    return q->count == MAX_SIZE;
}

// Check if queue is empty
bool isEmpty(struct Queue* q) {
    return q->count == 0;
}

// Enqueue operation - O(1)
void enqueue(struct Queue* q, int value) {
    if (isFull(q)) {
        printf("Queue Overflow! Cannot enqueue %d\\n", value);
        return;
    }
    
    // Circular increment
    q->rear = (q->rear + 1) % MAX_SIZE;
    q->items[q->rear] = value;
    q->count++;
    printf("Enqueued: %d\\n", value);
}

// Dequeue operation - O(1)
int dequeue(struct Queue* q) {
    if (isEmpty(q)) {
        printf("Queue Underflow!\\n");
        return -1;
    }
    
    int dequeued = q->items[q->front];
    q->front = (q->front + 1) % MAX_SIZE;
    q->count--;
    printf("Dequeued: %d\\n", dequeued);
    return dequeued;
}

// Get front element - O(1)
int getFront(struct Queue* q) {
    if (isEmpty(q)) {
        printf("Queue is empty!\\n");
        return -1;
    }
    return q->items[q->front];
}

// Display queue
void display(struct Queue* q) {
    if (isEmpty(q)) {
        printf("Queue is empty!\\n");
        return;
    }
    
    printf("Queue: ");
    int i = q->front;
    for (int j = 0; j < q->count; j++) {
        printf("%d ", q->items[i]);
        i = (i + 1) % MAX_SIZE;
    }
    printf("\\n");
}

int main() {
    struct Queue queue;
    initialize(&queue);
    
    enqueue(&queue, 10);
    enqueue(&queue, 20);
    enqueue(&queue, 30);
    
    display(&queue);
    printf("Front element: %d\\n", getFront(&queue));
    
    dequeue(&queue);
    display(&queue);
    
    // Test circular behavior
    enqueue(&queue, 40);
    enqueue(&queue, 50);
    enqueue(&queue, 60);  // Should wrap around
    
    display(&queue);
    
    return 0;
}''',
    timeComplexity: 'Enqueue: O(1), Dequeue: O(1), Front: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'FIFO - First In First Out',
      'Circular queue prevents memory waste',
      'All operations are O(1)',
      'Used in scheduling and BFS',
    ],
    iconName: 'queue',
    colorValue: 0xFF9B59B6,
  ),

  // 5. Binary Search
  DSProgram(
    id: 'binary_search',
    title: 'Binary Search Algorithm',
    topic: 'Searching',
    description: 'Efficient searching in sorted arrays',
    explanation: '''
Binary Search is a divide-and-conquer algorithm that finds elements in a SORTED array by repeatedly dividing the search space in half.

**How it works:**
1. Find the middle element
2. If target = middle: Found!
3. If target < middle: Search left half
4. If target > middle: Search right half
5. Repeat until found or search space exhausted

**Visual Example - Finding 23:**
[2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
 L              M                  R

[2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
                 L   M          R

[2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
                 L=M=R → Found!

**Requirement:** Array MUST be sorted!
''',
    code: '''#include <stdio.h>

// Iterative Binary Search - O(log n)
int binarySearchIterative(int arr[], int n, int target) {
    int left = 0;
    int right = n - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;  // Prevents overflow
        
        printf("Searching: left=%d, mid=%d, right=%d, arr[mid]=%d\\n", 
               left, mid, right, arr[mid]);
        
        if (arr[mid] == target) {
            return mid;  // Found!
        }
        else if (arr[mid] < target) {
            left = mid + 1;  // Search right half
        }
        else {
            right = mid - 1;  // Search left half
        }
    }
    
    return -1;  // Not found
}

// Recursive Binary Search - O(log n)
int binarySearchRecursive(int arr[], int left, int right, int target) {
    if (left > right) {
        return -1;  // Base case: not found
    }
    
    int mid = left + (right - left) / 2;
    
    if (arr[mid] == target) {
        return mid;
    }
    else if (arr[mid] < target) {
        return binarySearchRecursive(arr, mid + 1, right, target);
    }
    else {
        return binarySearchRecursive(arr, left, mid - 1, target);
    }
}

// Find first occurrence
int findFirst(int arr[], int n, int target) {
    int result = -1;
    int left = 0, right = n - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (arr[mid] == target) {
            result = mid;
            right = mid - 1;  // Continue searching left
        }
        else if (arr[mid] < target) {
            left = mid + 1;
        }
        else {
            right = mid - 1;
        }
    }
    
    return result;
}

int main() {
    int arr[] = {2, 5, 8, 12, 16, 23, 38, 56, 72, 91};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 23;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n\\nSearching for %d:\\n", target);
    
    int result = binarySearchIterative(arr, n, target);
    
    if (result != -1) {
        printf("\\nElement %d found at index %d\\n", target, result);
    } else {
        printf("\\nElement %d not found\\n", target);
    }
    
    return 0;
}''',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(1) iterative, O(log n) recursive',
    keyPoints: [
      'Works only on SORTED arrays',
      'Divides search space in half each time',
      'Much faster than linear search for large arrays',
      'Can find first/last occurrence with modifications',
    ],
    iconName: 'search',
    colorValue: 0xFF3498DB,
  ),

  // 6. Bubble Sort
  DSProgram(
    id: 'bubble_sort',
    title: 'Bubble Sort Algorithm',
    topic: 'Sorting',
    description: 'Simple comparison-based sorting',
    explanation: '''
Bubble Sort repeatedly steps through the list, compares adjacent elements, and swaps them if they're in the wrong order.

**How it works:**
• Compare adjacent elements
• Swap if left > right
• Largest elements "bubble up" to the end
• Repeat until no swaps needed

**Visual Example:**
Pass 1: [5,3,8,4,2] → [3,5,4,2,8]
Pass 2: [3,5,4,2,8] → [3,4,2,5,8]
Pass 3: [3,4,2,5,8] → [3,2,4,5,8]
Pass 4: [3,2,4,5,8] → [2,3,4,5,8] ✓

**Characteristics:**
• Simple to understand and implement
• Stable sort (maintains relative order)
• In-place (no extra memory)
• Not efficient for large datasets
''',
    code: '''#include <stdio.h>
#include <stdbool.h>

// Swap function
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Basic Bubble Sort - O(n²)
void bubbleSort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        printf("Pass %d: ", i + 1);
        
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(&arr[j], &arr[j + 1]);
            }
        }
        
        // Print array after each pass
        for (int k = 0; k < n; k++) {
            printf("%d ", arr[k]);
        }
        printf("\\n");
    }
}

// Optimized Bubble Sort - Stops early if sorted
void bubbleSortOptimized(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;
        
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(&arr[j], &arr[j + 1]);
                swapped = true;
            }
        }
        
        printf("Pass %d: ", i + 1);
        for (int k = 0; k < n; k++) {
            printf("%d ", arr[k]);
        }
        printf("\\n");
        
        // If no swapping occurred, array is sorted
        if (!swapped) {
            printf("Array is now sorted! Stopping early.\\n");
            break;
        }
    }
}

// Print array
void printArray(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

int main() {
    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    printf("Original array: ");
    printArray(arr, n);
    printf("\\n");
    
    printf("Sorting with Optimized Bubble Sort:\\n");
    bubbleSortOptimized(arr, n);
    
    printf("\\nSorted array: ");
    printArray(arr, n);
    
    return 0;
}''',
    timeComplexity: 'Best: O(n), Average: O(n²), Worst: O(n²)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Compares and swaps adjacent elements',
      'Largest element bubbles to end each pass',
      'Optimization: stop if no swaps in a pass',
      'Simple but inefficient for large data',
    ],
    iconName: 'sort',
    colorValue: 0xFFE74C3C,
  ),

  // 7. Binary Tree
  DSProgram(
    id: 'binary_tree',
    title: 'Binary Tree Traversals',
    topic: 'Trees',
    description: 'Inorder, Preorder, and Postorder traversals',
    explanation: '''
A Binary Tree is a hierarchical structure where each node has at most two children (left and right).

**Tree Structure:**
          1        ← Root
         / \\
        2   3      ← Children
       / \\   \\
      4   5   6    ← Leaves

**Traversal Orders:**

**Inorder (Left-Root-Right):** 4, 2, 5, 1, 3, 6
  - Gives sorted order for BST
  - Used in expression trees

**Preorder (Root-Left-Right):** 1, 2, 4, 5, 3, 6
  - Used to create copy of tree
  - Prefix expression

**Postorder (Left-Right-Root):** 4, 5, 2, 6, 3, 1
  - Used to delete tree
  - Postfix expression
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Tree Node structure
struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

// Create a new node
struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

// Inorder Traversal (Left - Root - Right)
void inorder(struct Node* root) {
    if (root != NULL) {
        inorder(root->left);
        printf("%d ", root->data);
        inorder(root->right);
    }
}

// Preorder Traversal (Root - Left - Right)
void preorder(struct Node* root) {
    if (root != NULL) {
        printf("%d ", root->data);
        preorder(root->left);
        preorder(root->right);
    }
}

// Postorder Traversal (Left - Right - Root)
void postorder(struct Node* root) {
    if (root != NULL) {
        postorder(root->left);
        postorder(root->right);
        printf("%d ", root->data);
    }
}

// Calculate height of tree
int height(struct Node* root) {
    if (root == NULL) {
        return 0;
    }
    
    int leftHeight = height(root->left);
    int rightHeight = height(root->right);
    
    return (leftHeight > rightHeight ? leftHeight : rightHeight) + 1;
}

// Count total nodes
int countNodes(struct Node* root) {
    if (root == NULL) {
        return 0;
    }
    return 1 + countNodes(root->left) + countNodes(root->right);
}

int main() {
    /*
        Creating this tree:
              1
             / \\
            2   3
           / \\   \\
          4   5   6
    */
    
    struct Node* root = createNode(1);
    root->left = createNode(2);
    root->right = createNode(3);
    root->left->left = createNode(4);
    root->left->right = createNode(5);
    root->right->right = createNode(6);
    
    printf("Binary Tree Traversals:\\n\\n");
    
    printf("Inorder (L-Root-R):   ");
    inorder(root);
    printf("\\n");
    
    printf("Preorder (Root-L-R):  ");
    preorder(root);
    printf("\\n");
    
    printf("Postorder (L-R-Root): ");
    postorder(root);
    printf("\\n\\n");
    
    printf("Tree Height: %d\\n", height(root));
    printf("Total Nodes: %d\\n", countNodes(root));
    
    return 0;
}''',
    timeComplexity: 'Traversal: O(n), Height: O(n)',
    spaceComplexity: 'O(h) where h is height (recursion stack)',
    keyPoints: [
      'Each node has at most 2 children',
      'Inorder gives sorted order for BST',
      'Preorder used for tree copying',
      'Postorder used for tree deletion',
    ],
    iconName: 'account_tree',
    colorValue: 0xFF27AE60,
  ),

  // 8. Recursion
  DSProgram(
    id: 'recursion',
    title: 'Recursion - Factorial & Fibonacci',
    topic: 'Recursion',
    description: 'Understanding recursive problem solving',
    explanation: '''
Recursion is a technique where a function calls itself to solve smaller instances of the same problem.

**Key Components:**
1. **Base Case:** Condition to stop recursion
2. **Recursive Case:** Function calls itself

**Factorial Example:**
5! = 5 × 4!
   = 5 × 4 × 3!
   = 5 × 4 × 3 × 2!
   = 5 × 4 × 3 × 2 × 1!
   = 5 × 4 × 3 × 2 × 1 = 120

**Fibonacci Sequence:**
0, 1, 1, 2, 3, 5, 8, 13, 21, 34...
F(n) = F(n-1) + F(n-2)

**Call Stack for factorial(3):**
factorial(3)
  └→ factorial(2)
       └→ factorial(1) ← Base case returns 1
          └→ Returns 1
       └→ Returns 2 × 1 = 2
  └→ Returns 3 × 2 = 6
''',
    code: '''#include <stdio.h>

// Factorial using recursion
long long factorialRecursive(int n) {
    printf("factorial(%d) called\\n", n);
    
    // Base case
    if (n == 0 || n == 1) {
        return 1;
    }
    
    // Recursive case
    return n * factorialRecursive(n - 1);
}

// Factorial using iteration (for comparison)
long long factorialIterative(int n) {
    long long result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

// Fibonacci using recursion (inefficient)
int fibRecursive(int n) {
    if (n <= 1) {
        return n;
    }
    return fibRecursive(n - 1) + fibRecursive(n - 2);
}

// Fibonacci with memoization (efficient)
int fibMemo[100] = {0};
int fibMemoized(int n) {
    if (n <= 1) {
        return n;
    }
    
    // Check if already calculated
    if (fibMemo[n] != 0) {
        return fibMemo[n];
    }
    
    // Calculate and store
    fibMemo[n] = fibMemoized(n - 1) + fibMemoized(n - 2);
    return fibMemo[n];
}

// Sum of digits using recursion
int sumOfDigits(int n) {
    if (n == 0) {
        return 0;
    }
    return (n % 10) + sumOfDigits(n / 10);
}

// Power function using recursion
int power(int base, int exp) {
    if (exp == 0) {
        return 1;
    }
    return base * power(base, exp - 1);
}

int main() {
    printf("=== FACTORIAL ===\\n");
    int n = 5;
    printf("\\n%d! = %lld\\n", n, factorialRecursive(n));
    
    printf("\\n=== FIBONACCI ===\\n");
    printf("First 10 Fibonacci numbers: ");
    for (int i = 0; i < 10; i++) {
        printf("%d ", fibMemoized(i));
    }
    printf("\\n");
    
    printf("\\n=== SUM OF DIGITS ===\\n");
    int num = 12345;
    printf("Sum of digits of %d = %d\\n", num, sumOfDigits(num));
    
    printf("\\n=== POWER ===\\n");
    printf("2^10 = %d\\n", power(2, 10));
    
    return 0;
}''',
    timeComplexity: 'Factorial: O(n), Fibonacci: O(2^n) naive, O(n) memoized',
    spaceComplexity: 'O(n) for recursion stack',
    keyPoints: [
      'Every recursion needs a base case',
      'Problems solved by smaller subproblems',
      'Can be converted to iteration',
      'Memoization improves efficiency',
    ],
    iconName: 'loop',
    colorValue: 0xFFF39C12,
  ),

  // 9. Strings
  DSProgram(
    id: 'strings',
    title: 'String Manipulation',
    topic: 'Strings',
    description: 'String operations and algorithms',
    explanation: '''
In C, strings are arrays of characters terminated by a null character '\\0'.

**String Representation:**
"Hello" → ['H']['e']['l']['l']['o']['\\0']
            0    1    2    3    4    5

**Common Operations:**
• strlen() - Length of string
• strcpy() - Copy string
• strcat() - Concatenate strings
• strcmp() - Compare strings
• strrev() - Reverse string

**Important Points:**
1. Always allocate space for null terminator
2. Use sizeof or strlen carefully
3. Buffer overflow is a common bug
4. Strings are immutable in many languages (not C)
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <ctype.h>

// Calculate string length manually
int myStrlen(char str[]) {
    int count = 0;
    while (str[count] != '\\0') {
        count++;
    }
    return count;
}

// Copy string manually
void myStrcpy(char dest[], char src[]) {
    int i = 0;
    while (src[i] != '\\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\\0';
}

// Reverse string in-place
void reverseString(char str[]) {
    int left = 0;
    int right = myStrlen(str) - 1;
    
    while (left < right) {
        char temp = str[left];
        str[left] = str[right];
        str[right] = temp;
        left++;
        right--;
    }
}

// Check palindrome
int isPalindrome(char str[]) {
    int left = 0;
    int right = myStrlen(str) - 1;
    
    while (left < right) {
        if (str[left] != str[right]) {
            return 0;  // Not palindrome
        }
        left++;
        right--;
    }
    return 1;  // Palindrome
}

// Count vowels and consonants
void countVowelsConsonants(char str[], int* vowels, int* consonants) {
    *vowels = 0;
    *consonants = 0;
    
    for (int i = 0; str[i] != '\\0'; i++) {
        char c = tolower(str[i]);
        if (c >= 'a' && c <= 'z') {
            if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
                (*vowels)++;
            } else {
                (*consonants)++;
            }
        }
    }
}

// Remove spaces from string
void removeSpaces(char str[]) {
    int i = 0, j = 0;
    while (str[i] != '\\0') {
        if (str[i] != ' ') {
            str[j++] = str[i];
        }
        i++;
    }
    str[j] = '\\0';
}

int main() {
    char str1[] = "Hello World";
    char str2[] = "madam";
    char str3[50];
    
    printf("Original string: %s\\n", str1);
    printf("Length: %d\\n\\n", myStrlen(str1));
    
    // Copy string
    myStrcpy(str3, str1);
    printf("Copied string: %s\\n\\n", str3);
    
    // Reverse
    printf("Before reverse: %s\\n", str1);
    reverseString(str1);
    printf("After reverse: %s\\n\\n", str1);
    
    // Palindrome check
    printf("Is '%s' a palindrome? %s\\n\\n", 
           str2, isPalindrome(str2) ? "Yes" : "No");
    
    // Count vowels and consonants
    int v, c;
    countVowelsConsonants("Programming", &v, &c);
    printf("'Programming' - Vowels: %d, Consonants: %d\\n\\n", v, c);
    
    // Remove spaces
    char spaceStr[] = "H e l l o";
    printf("Before removing spaces: '%s'\\n", spaceStr);
    removeSpaces(spaceStr);
    printf("After removing spaces: '%s'\\n", spaceStr);
    
    return 0;
}''',
    timeComplexity: 'Most operations: O(n)',
    spaceComplexity: 'O(1) for in-place operations',
    keyPoints: [
      'Strings are null-terminated char arrays',
      'Always account for \\0 in size',
      'Two pointers technique for many problems',
      'Be careful of buffer overflows',
    ],
    iconName: 'text_fields',
    colorValue: 0xFF1ABC9C,
  ),

  // 10. Pointers
  DSProgram(
    id: 'pointers',
    title: 'Pointers & Memory',
    topic: 'Pointers',
    description: 'Understanding memory addresses and pointer operations',
    explanation: '''
A pointer is a variable that stores the memory address of another variable.

**Pointer Visualization:**
  int x = 10;     Memory Address: 0x1000
  int *p = &x;    Memory Address: 0x2000
  
  [0x1000]: 10    ← x stores value 10
  [0x2000]: 0x1000 ← p stores address of x

**Key Operators:**
• & (Address-of): Gets the address
• * (Dereference): Gets the value at address

**Pointer Arithmetic:**
• For int* p: p + 1 moves 4 bytes ahead
• For char* p: p + 1 moves 1 byte ahead
• Depends on data type size

**Uses of Pointers:**
1. Dynamic memory allocation
2. Pass by reference
3. Arrays and strings
4. Data structures (linked lists, trees)
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Swap using pointers (Pass by Reference)
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Return multiple values using pointers
void getMinMax(int arr[], int n, int *min, int *max) {
    *min = arr[0];
    *max = arr[0];
    
    for (int i = 1; i < n; i++) {
        if (arr[i] < *min) *min = arr[i];
        if (arr[i] > *max) *max = arr[i];
    }
}

// Pointer to pointer
void modifyPointer(int **pp) {
    static int newValue = 100;
    *pp = &newValue;  // Change what pointer points to
}

int main() {
    printf("=== BASIC POINTER OPERATIONS ===\\n");
    int x = 10;
    int *p = &x;  // p stores address of x
    
    printf("Value of x: %d\\n", x);
    printf("Address of x (&x): %p\\n", (void*)&x);
    printf("Value of p: %p\\n", (void*)p);
    printf("Value at *p: %d\\n", *p);
    
    *p = 20;  // Modify x through pointer
    printf("After *p = 20, x = %d\\n\\n", x);
    
    printf("=== SWAP USING POINTERS ===\\n");
    int a = 5, b = 10;
    printf("Before swap: a = %d, b = %d\\n", a, b);
    swap(&a, &b);
    printf("After swap: a = %d, b = %d\\n\\n", a, b);
    
    printf("=== POINTER ARITHMETIC ===\\n");
    int arr[] = {10, 20, 30, 40, 50};
    int *ptr = arr;  // Points to first element
    
    for (int i = 0; i < 5; i++) {
        printf("*(ptr + %d) = %d\\n", i, *(ptr + i));
    }
    printf("\\n");
    
    printf("=== ARRAY WITH POINTERS ===\\n");
    int min, max;
    getMinMax(arr, 5, &min, &max);
    printf("Array: ");
    for (int i = 0; i < 5; i++) printf("%d ", arr[i]);
    printf("\\nMin: %d, Max: %d\\n\\n", min, max);
    
    printf("=== DYNAMIC MEMORY ===\\n");
    int n = 5;
    int *dynArr = (int*)malloc(n * sizeof(int));
    
    if (dynArr == NULL) {
        printf("Memory allocation failed!\\n");
        return 1;
    }
    
    // Initialize
    for (int i = 0; i < n; i++) {
        dynArr[i] = (i + 1) * 10;
    }
    
    printf("Dynamic array: ");
    for (int i = 0; i < n; i++) {
        printf("%d ", dynArr[i]);
    }
    printf("\\n");
    
    free(dynArr);  // Always free allocated memory!
    printf("Memory freed successfully\\n");
    
    return 0;
}''',
    timeComplexity: 'Pointer operations: O(1)',
    spaceComplexity: 'Pointers: O(1) each (4 or 8 bytes)',
    keyPoints: [
      '& gives address, * gives value at address',
      'Pointer arithmetic depends on data type',
      'Always free dynamically allocated memory',
      'NULL check before dereferencing',
    ],
    iconName: 'memory',
    colorValue: 0xFF8E44AD,
  ),
];
