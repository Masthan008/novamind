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

  // Arrays - Program 2: Reverse Array
  DSProgram(
    id: 'arrays_reverse',
    title: 'Reverse an Array',
    topic: 'Arrays',
    description: 'Multiple methods to reverse array elements',
    explanation: '''
Reversing an array means rearranging elements so that the first becomes last and last becomes first.

**Methods to Reverse:**
1. Using Two Pointers (In-place) - O(n) time, O(1) space
2. Using Extra Array - O(n) time, O(n) space
3. Using Recursion - O(n) time, O(n) stack space

**Two Pointer Approach:**
Original: [1, 2, 3, 4, 5]
          ↑           ↑
         left       right
         
Swap left and right, move towards center:
Step 1: [5, 2, 3, 4, 1] → swap(1,5)
Step 2: [5, 4, 3, 2, 1] → swap(2,4)
Done when left >= right
''',
    code: '''#include <stdio.h>

// Method 1: Two Pointers (Most Efficient)
void reverseInPlace(int arr[], int n) {
    int left = 0;
    int right = n - 1;
    
    while (left < right) {
        // Swap elements
        int temp = arr[left];
        arr[left] = arr[right];
        arr[right] = temp;
        
        left++;
        right--;
    }
}

// Method 2: Using Extra Array
void reverseWithExtra(int arr[], int n, int result[]) {
    for (int i = 0; i < n; i++) {
        result[i] = arr[n - 1 - i];
    }
}

// Method 3: Recursive approach
void reverseRecursive(int arr[], int left, int right) {
    if (left >= right) {
        return;  // Base case
    }
    
    // Swap
    int temp = arr[left];
    arr[left] = arr[right];
    arr[right] = temp;
    
    reverseRecursive(arr, left + 1, right - 1);
}

void printArray(int arr[], int n, char* msg) {
    printf("%s: ", msg);
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

int main() {
    int arr1[] = {1, 2, 3, 4, 5};
    int n = 5;
    
    printArray(arr1, n, "Original");
    
    // Method 1: In-place
    reverseInPlace(arr1, n);
    printArray(arr1, n, "After in-place reverse");
    
    // Method 2: Extra array
    int arr2[] = {10, 20, 30, 40};
    int result[4];
    reverseWithExtra(arr2, 4, result);
    printArray(result, 4, "Using extra array");
    
    // Method 3: Recursive
    int arr3[] = {5, 10, 15, 20, 25};
    reverseRecursive(arr3, 0, 4);
    printArray(arr3, 5, "Recursive reverse");
    
    return 0;
}''',
    timeComplexity: 'O(n) for all methods',
    spaceComplexity: 'O(1) in-place, O(n) extra array/recursion',
    keyPoints: [
      'Two pointer approach is most space-efficient',
      'Swap elements from both ends moving towards center',
      'Recursion uses stack space implicitly',
      'XOR swap can avoid temp variable',
    ],
    iconName: 'swap_horiz',
    colorValue: 0xFFFF6B6B,
  ),

  // Arrays - Program 3: Find Maximum and Minimum
  DSProgram(
    id: 'arrays_maxmin',
    title: 'Find Max and Min Element',
    topic: 'Arrays',
    description: 'Find largest and smallest elements efficiently',
    explanation: '''
Finding maximum and minimum elements in an array is a fundamental operation.

**Methods:**
1. Linear Search - Compare each element
2. Tournament Method - Divide and conquer
3. Compare in Pairs - Reduces comparisons

**Linear Search:**
• Traverse entire array once
• Track min and max as we go
• Time: O(n), Comparisons: 2(n-1)

**Compare in Pairs (Optimal):**
• Compare elements in pairs first
• Then compare with min/max
• Comparisons reduced to 3n/2 - 2

**Example:**
Array: [3, 5, 1, 8, 2]
• Initialize: min = max = 3
• Compare 5: max = 5
• Compare 1: min = 1
• Compare 8: max = 8
• Compare 2: no change
Result: min = 1, max = 8
''',
    code: '''#include <stdio.h>
#include <limits.h>

// Method 1: Simple Linear Scan
void findMinMaxSimple(int arr[], int n, int *min, int *max) {
    *min = arr[0];
    *max = arr[0];
    
    for (int i = 1; i < n; i++) {
        if (arr[i] < *min) {
            *min = arr[i];
        }
        if (arr[i] > *max) {
            *max = arr[i];
        }
    }
}

// Method 2: Compare in Pairs (Fewer comparisons)
void findMinMaxOptimal(int arr[], int n, int *min, int *max) {
    int i;
    
    // Initialize based on array size
    if (n % 2 == 0) {
        if (arr[0] > arr[1]) {
            *max = arr[0];
            *min = arr[1];
        } else {
            *max = arr[1];
            *min = arr[0];
        }
        i = 2;
    } else {
        *min = *max = arr[0];
        i = 1;
    }
    
    // Compare in pairs
    while (i < n - 1) {
        if (arr[i] > arr[i + 1]) {
            if (arr[i] > *max) *max = arr[i];
            if (arr[i + 1] < *min) *min = arr[i + 1];
        } else {
            if (arr[i + 1] > *max) *max = arr[i + 1];
            if (arr[i] < *min) *min = arr[i];
        }
        i += 2;
    }
}

// Method 3: Find Second Largest also
void findTopTwo(int arr[], int n, int *first, int *second) {
    *first = *second = INT_MIN;
    
    for (int i = 0; i < n; i++) {
        if (arr[i] > *first) {
            *second = *first;
            *first = arr[i];
        } else if (arr[i] > *second && arr[i] != *first) {
            *second = arr[i];
        }
    }
}

int main() {
    int arr[] = {3, 5, 1, 8, 2, 9, 4};
    int n = sizeof(arr) / sizeof(arr[0]);
    int min, max;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\n");
    
    // Method 1
    findMinMaxSimple(arr, n, &min, &max);
    printf("Simple Method: Min = %d, Max = %d\\n", min, max);
    
    // Method 2
    findMinMaxOptimal(arr, n, &min, &max);
    printf("Optimal Method: Min = %d, Max = %d\\n", min, max);
    
    // Find top two
    int first, second;
    findTopTwo(arr, n, &first, &second);
    printf("\\nTop two elements: %d, %d\\n", first, second);
    
    return 0;
}''',
    timeComplexity: 'O(n) for all methods',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Simple linear scan is easy to implement',
      'Pair comparison reduces total comparisons',
      'Can find second max/min in same pass',
      'Initialize min to INT_MAX, max to INT_MIN for safety',
    ],
    iconName: 'trending_up',
    colorValue: 0xFFFF6B6B,
  ),

  // Arrays - Program 4: Merge Two Sorted Arrays
  DSProgram(
    id: 'arrays_merge',
    title: 'Merge Two Sorted Arrays',
    topic: 'Arrays',
    description: 'Combine two sorted arrays into one sorted array',
    explanation: '''
Merging two sorted arrays produces a single sorted array containing all elements.

**Algorithm (Two Pointer):**
1. Use two pointers, one for each array
2. Compare elements at both pointers
3. Copy smaller element to result
4. Move pointer of copied element forward
5. Repeat until one array is exhausted
6. Copy remaining elements

**Visual Example:**
Array1: [1, 3, 5]  i→
Array2: [2, 4, 6]  j→
Result: []

Compare 1 vs 2 → copy 1: [1]
Compare 3 vs 2 → copy 2: [1, 2]
Compare 3 vs 4 → copy 3: [1, 2, 3]
Compare 5 vs 4 → copy 4: [1, 2, 3, 4]
Compare 5 vs 6 → copy 5: [1, 2, 3, 4, 5]
Copy remaining 6: [1, 2, 3, 4, 5, 6]

**Key Insight:** This is the merge step in Merge Sort!
''',
    code: '''#include <stdio.h>

// Merge two sorted arrays
void mergeSorted(int arr1[], int n1, int arr2[], int n2, int result[]) {
    int i = 0, j = 0, k = 0;
    
    // Compare and merge
    while (i < n1 && j < n2) {
        if (arr1[i] <= arr2[j]) {
            result[k++] = arr1[i++];
        } else {
            result[k++] = arr2[j++];
        }
    }
    
    // Copy remaining from arr1
    while (i < n1) {
        result[k++] = arr1[i++];
    }
    
    // Copy remaining from arr2
    while (j < n2) {
        result[k++] = arr2[j++];
    }
}

// Merge with duplicates removed
int mergeSortedUnique(int arr1[], int n1, int arr2[], int n2, int result[]) {
    int i = 0, j = 0, k = 0;
    
    while (i < n1 && j < n2) {
        if (arr1[i] < arr2[j]) {
            if (k == 0 || result[k-1] != arr1[i]) {
                result[k++] = arr1[i];
            }
            i++;
        } else if (arr1[i] > arr2[j]) {
            if (k == 0 || result[k-1] != arr2[j]) {
                result[k++] = arr2[j];
            }
            j++;
        } else {
            // Equal elements
            if (k == 0 || result[k-1] != arr1[i]) {
                result[k++] = arr1[i];
            }
            i++;
            j++;
        }
    }
    
    while (i < n1) {
        if (k == 0 || result[k-1] != arr1[i]) {
            result[k++] = arr1[i];
        }
        i++;
    }
    
    while (j < n2) {
        if (k == 0 || result[k-1] != arr2[j]) {
            result[k++] = arr2[j];
        }
        j++;
    }
    
    return k;  // Return new size
}

void printArray(int arr[], int n, char* label) {
    printf("%s: ", label);
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

int main() {
    int arr1[] = {1, 3, 5, 7, 9};
    int arr2[] = {2, 4, 6, 8, 10};
    int n1 = 5, n2 = 5;
    int result[10];
    
    printArray(arr1, n1, "Array 1");
    printArray(arr2, n2, "Array 2");
    
    mergeSorted(arr1, n1, arr2, n2, result);
    printArray(result, n1 + n2, "Merged");
    
    // Test with duplicates
    printf("\\n--- With Duplicates ---\\n");
    int a[] = {1, 3, 3, 5};
    int b[] = {2, 3, 4, 5};
    int unique[8];
    
    printArray(a, 4, "Array A");
    printArray(b, 4, "Array B");
    
    int newSize = mergeSortedUnique(a, 4, b, 4, unique);
    printArray(unique, newSize, "Merged Unique");
    
    return 0;
}''',
    timeComplexity: 'O(n + m) where n, m are array sizes',
    spaceComplexity: 'O(n + m) for result array',
    keyPoints: [
      'Both input arrays must be sorted',
      'Two pointer technique is key',
      'Used as merge step in Merge Sort',
      'Can handle duplicates with slight modification',
    ],
    iconName: 'merge_type',
    colorValue: 0xFFFF6B6B,
  ),

  // Arrays - Program 5: Remove Duplicates
  DSProgram(
    id: 'arrays_duplicates',
    title: 'Remove Duplicates from Array',
    topic: 'Arrays',
    description: 'Remove duplicate elements from sorted and unsorted arrays',
    explanation: '''
Removing duplicates creates an array with only unique elements.

**For Sorted Array (Optimal):**
• Use two pointers: one for reading, one for writing
• Only write when current != previous
• In-place, O(1) extra space

**For Unsorted Array:**
Method 1: Sort first, then use sorted algorithm
Method 2: Use hash set (O(n) time, O(n) space)
Method 3: Nested loops (O(n²) time, O(1) space)

**Sorted Array Example:**
Input:  [1, 1, 2, 2, 2, 3, 4, 4]
         ↑        
        write     read
        
Output: [1, 2, 3, 4, _, _, _, _]
New length: 4
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Method 1: Remove duplicates from SORTED array (In-place)
int removeDuplicatesSorted(int arr[], int n) {
    if (n == 0) return 0;
    
    int writeIndex = 1;  // Position to write next unique
    
    for (int readIndex = 1; readIndex < n; readIndex++) {
        // If current is different from previous unique
        if (arr[readIndex] != arr[writeIndex - 1]) {
            arr[writeIndex] = arr[readIndex];
            writeIndex++;
        }
    }
    
    return writeIndex;  // New size
}

// Method 2: Remove duplicates from UNSORTED array
// Returns new size
int removeDuplicatesUnsorted(int arr[], int n) {
    if (n <= 1) return n;
    
    int newSize = 1;
    
    for (int i = 1; i < n; i++) {
        int isDuplicate = 0;
        
        // Check if arr[i] exists in result portion
        for (int j = 0; j < newSize; j++) {
            if (arr[i] == arr[j]) {
                isDuplicate = 1;
                break;
            }
        }
        
        // If not duplicate, add to result
        if (!isDuplicate) {
            arr[newSize] = arr[i];
            newSize++;
        }
    }
    
    return newSize;
}

// Method 3: Count occurrences of each element
void countDuplicates(int arr[], int n) {
    printf("\\nElement frequencies:\\n");
    
    // Mark visited elements as -1 (assuming positive numbers)
    int *visited = (int*)calloc(n, sizeof(int));
    
    for (int i = 0; i < n; i++) {
        if (visited[i]) continue;
        
        int count = 1;
        for (int j = i + 1; j < n; j++) {
            if (arr[i] == arr[j]) {
                count++;
                visited[j] = 1;
            }
        }
        
        if (count > 1) {
            printf("%d appears %d times\\n", arr[i], count);
        }
    }
    
    free(visited);
}

void printArray(int arr[], int n, char* msg) {
    printf("%s: ", msg);
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

int main() {
    // Test sorted array
    printf("=== SORTED ARRAY ===\\n");
    int sorted[] = {1, 1, 2, 2, 2, 3, 4, 4, 5};
    int n1 = 9;
    
    printArray(sorted, n1, "Original");
    int newSize1 = removeDuplicatesSorted(sorted, n1);
    printArray(sorted, newSize1, "After removing duplicates");
    printf("New size: %d\\n", newSize1);
    
    // Test unsorted array
    printf("\\n=== UNSORTED ARRAY ===\\n");
    int unsorted[] = {4, 2, 4, 1, 2, 3, 4, 1, 5};
    int n2 = 9;
    
    printArray(unsorted, n2, "Original");
    int newSize2 = removeDuplicatesUnsorted(unsorted, n2);
    printArray(unsorted, newSize2, "After removing duplicates");
    printf("New size: %d\\n", newSize2);
    
    // Count duplicates
    int arr3[] = {1, 2, 2, 3, 3, 3, 4, 4, 4, 4};
    countDuplicates(arr3, 10);
    
    return 0;
}''',
    timeComplexity: 'Sorted: O(n), Unsorted: O(n²)',
    spaceComplexity: 'O(1) in-place',
    keyPoints: [
      'Sorted arrays allow O(n) solution',
      'Two pointer technique for in-place removal',
      'Unsorted arrays need sorting or hashing',
      'Original array is modified - copy if needed',
    ],
    iconName: 'filter_list',
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

  // Linked Lists - Program 2: Doubly Linked List
  DSProgram(
    id: 'linked_list_doubly',
    title: 'Doubly Linked List',
    topic: 'Linked Lists',
    description: 'Two-way traversal linked list with prev and next pointers',
    explanation: '''
A Doubly Linked List has nodes that point to both previous and next nodes.

**Structure:**
NULL ← [10] ⇔ [20] ⇔ [30] ⇔ [40] → NULL
        Head                   Tail

**Advantages over Singly LL:**
• Bidirectional traversal
• O(1) deletion when node is known
• Easier insertion before a node

**Disadvantages:**
• Extra memory for prev pointer
• More complex implementation

**Operations:**
• Insert at head/tail: O(1)
• Delete at head/tail: O(1)
• Delete any node: O(1) if pointer given
• Search: O(n)
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Node structure
struct Node {
    int data;
    struct Node* prev;
    struct Node* next;
};

struct Node* head = NULL;
struct Node* tail = NULL;

// Create new node
struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->prev = NULL;
    newNode->next = NULL;
    return newNode;
}

// Insert at beginning - O(1)
void insertAtHead(int data) {
    struct Node* newNode = createNode(data);
    
    if (head == NULL) {
        head = tail = newNode;
    } else {
        newNode->next = head;
        head->prev = newNode;
        head = newNode;
    }
    printf("Inserted %d at head\\n", data);
}

// Insert at end - O(1)
void insertAtTail(int data) {
    struct Node* newNode = createNode(data);
    
    if (tail == NULL) {
        head = tail = newNode;
    } else {
        tail->next = newNode;
        newNode->prev = tail;
        tail = newNode;
    }
    printf("Inserted %d at tail\\n", data);
}

// Delete a node - O(1) when node pointer given
void deleteNode(struct Node* node) {
    if (node == NULL) return;
    
    if (node == head) {
        head = node->next;
        if (head) head->prev = NULL;
    } else if (node == tail) {
        tail = node->prev;
        if (tail) tail->next = NULL;
    } else {
        node->prev->next = node->next;
        node->next->prev = node->prev;
    }
    
    printf("Deleted %d\\n", node->data);
    free(node);
}

// Display forward
void displayForward() {
    printf("Forward: ");
    struct Node* temp = head;
    while (temp) {
        printf("%d <-> ", temp->data);
        temp = temp->next;
    }
    printf("NULL\\n");
}

// Display backward
void displayBackward() {
    printf("Backward: ");
    struct Node* temp = tail;
    while (temp) {
        printf("%d <-> ", temp->data);
        temp = temp->prev;
    }
    printf("NULL\\n");
}

int main() {
    insertAtHead(20);
    insertAtHead(10);
    insertAtTail(30);
    insertAtTail(40);
    
    displayForward();
    displayBackward();
    
    // Delete middle node (30)
    deleteNode(head->next->next);  // Points to 30
    displayForward();
    
    return 0;
}''',
    timeComplexity: 'Insert/Delete head/tail: O(1), Search: O(n)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Each node has both prev and next pointers',
      'Allows bidirectional traversal',
      'O(1) deletion when node pointer is known',
      'Uses more memory than singly linked list',
    ],
    iconName: 'swap_calls',
    colorValue: 0xFF4ECDC4,
  ),

  // Linked Lists - Program 3: Reverse Linked List
  DSProgram(
    id: 'linked_list_reverse',
    title: 'Reverse a Linked List',
    topic: 'Linked Lists',
    description: 'Multiple methods to reverse a singly linked list',
    explanation: '''
Reversing a linked list changes the direction of all next pointers.

**Iterative Method:**
Original: 1 → 2 → 3 → 4 → NULL
Reversed: 4 → 3 → 2 → 1 → NULL

**Algorithm (3 pointers):**
1. prev = NULL, curr = head
2. For each node:
   - Save next: temp = curr->next
   - Reverse link: curr->next = prev
   - Move pointers: prev = curr, curr = temp
3. Return prev as new head

**Visual Steps:**
NULL ← 1    2 → 3 → 4 → NULL
      ↑    ↑
     prev curr

NULL ← 1 ← 2    3 → 4 → NULL
           ↑    ↑
          prev curr

...and so on
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

// Method 1: Iterative Reverse - O(n) time, O(1) space
struct Node* reverseIterative(struct Node* head) {
    struct Node* prev = NULL;
    struct Node* curr = head;
    struct Node* next = NULL;
    
    while (curr != NULL) {
        next = curr->next;    // Save next
        curr->next = prev;    // Reverse link
        prev = curr;          // Move prev forward
        curr = next;          // Move curr forward
    }
    
    return prev;  // New head
}

// Method 2: Recursive Reverse - O(n) time, O(n) stack space
struct Node* reverseRecursive(struct Node* head) {
    // Base case
    if (head == NULL || head->next == NULL) {
        return head;
    }
    
    // Recursively reverse rest
    struct Node* newHead = reverseRecursive(head->next);
    
    // Make next node point back to current
    head->next->next = head;
    head->next = NULL;
    
    return newHead;
}

// Method 3: Reverse in groups of K
struct Node* reverseKGroup(struct Node* head, int k) {
    struct Node* curr = head;
    struct Node* prev = NULL;
    struct Node* next = NULL;
    int count = 0;
    
    // Reverse first k nodes
    while (curr != NULL && count < k) {
        next = curr->next;
        curr->next = prev;
        prev = curr;
        curr = next;
        count++;
    }
    
    // Recursively reverse remaining
    if (next != NULL) {
        head->next = reverseKGroup(next, k);
    }
    
    return prev;
}

void display(struct Node* head) {
    while (head) {
        printf("%d -> ", head->data);
        head = head->next;
    }
    printf("NULL\\n");
}

int main() {
    // Create list: 1 -> 2 -> 3 -> 4 -> 5
    struct Node* head = createNode(1);
    head->next = createNode(2);
    head->next->next = createNode(3);
    head->next->next->next = createNode(4);
    head->next->next->next->next = createNode(5);
    
    printf("Original: ");
    display(head);
    
    // Iterative reverse
    head = reverseIterative(head);
    printf("After iterative reverse: ");
    display(head);
    
    // Reverse back using recursive
    head = reverseRecursive(head);
    printf("After recursive reverse: ");
    display(head);
    
    // Reverse in groups of 2
    head = reverseKGroup(head, 2);
    printf("Reversed in groups of 2: ");
    display(head);
    
    return 0;
}''',
    timeComplexity: 'O(n) for all methods',
    spaceComplexity: 'O(1) iterative, O(n) recursive',
    keyPoints: [
      'Iterative uses 3 pointers: prev, curr, next',
      'Recursive reverses from end to beginning',
      'Can reverse in groups for specific patterns',
      'Common interview question',
    ],
    iconName: 'undo',
    colorValue: 0xFF4ECDC4,
  ),

  // Linked Lists - Program 4: Detect Cycle
  DSProgram(
    id: 'linked_list_cycle',
    title: 'Detect Cycle in Linked List',
    topic: 'Linked Lists',
    description: "Floyd's Cycle Detection Algorithm (Tortoise and Hare)",
    explanation: '''
A cycle exists when a node's next points to an earlier node.

**Floyd's Algorithm (Two Pointers):**
• Slow pointer moves 1 step
• Fast pointer moves 2 steps
• If they meet, cycle exists!

**Why it works:**
If there's a cycle, fast will "lap" slow inside the cycle.
Like two runners on a track - faster one catches slower.

**Visual Example (with cycle):**
1 → 2 → 3 → 4 → 5
        ↑       ↓
        └───────┘

• After 3 steps: slow at 4, fast at 4 → DETECTED!

**Finding Cycle Start:**
After detection, reset one pointer to head.
Move both 1 step at a time.
They meet at cycle start!
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

// Floyd's Cycle Detection - O(n) time, O(1) space
bool hasCycle(struct Node* head) {
    if (head == NULL) return false;
    
    struct Node* slow = head;
    struct Node* fast = head;
    
    while (fast != NULL && fast->next != NULL) {
        slow = slow->next;          // Move 1 step
        fast = fast->next->next;    // Move 2 steps
        
        if (slow == fast) {
            return true;  // Cycle detected!
        }
    }
    
    return false;  // No cycle
}

// Find the start of the cycle
struct Node* findCycleStart(struct Node* head) {
    if (head == NULL) return NULL;
    
    struct Node* slow = head;
    struct Node* fast = head;
    
    // Detect cycle
    while (fast != NULL && fast->next != NULL) {
        slow = slow->next;
        fast = fast->next->next;
        
        if (slow == fast) {
            // Cycle found, now find start
            slow = head;
            while (slow != fast) {
                slow = slow->next;
                fast = fast->next;
            }
            return slow;  // Start of cycle
        }
    }
    
    return NULL;  // No cycle
}

// Find cycle length
int cycleLength(struct Node* head) {
    struct Node* slow = head;
    struct Node* fast = head;
    
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        
        if (slow == fast) {
            // Count cycle length
            int length = 1;
            struct Node* temp = slow->next;
            while (temp != slow) {
                length++;
                temp = temp->next;
            }
            return length;
        }
    }
    
    return 0;  // No cycle
}

int main() {
    // Create list: 1 -> 2 -> 3 -> 4 -> 5
    struct Node* head = createNode(1);
    head->next = createNode(2);
    head->next->next = createNode(3);
    head->next->next->next = createNode(4);
    head->next->next->next->next = createNode(5);
    
    printf("Without cycle: %s\\n", hasCycle(head) ? "Has cycle" : "No cycle");
    
    // Create a cycle: 5 -> 3
    head->next->next->next->next->next = head->next->next;
    
    printf("After adding cycle: %s\\n", hasCycle(head) ? "Has cycle" : "No cycle");
    
    struct Node* cycleStart = findCycleStart(head);
    if (cycleStart) {
        printf("Cycle starts at node with value: %d\\n", cycleStart->data);
    }
    
    printf("Cycle length: %d\\n", cycleLength(head));
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      "Floyd's algorithm uses slow and fast pointers",
      'Fast pointer moves twice as fast as slow',
      'If they meet, cycle exists',
      'Can find cycle start and length',
    ],
    iconName: 'loop',
    colorValue: 0xFF4ECDC4,
  ),

  // Linked Lists - Program 5: Find Middle Element
  DSProgram(
    id: 'linked_list_middle',
    title: 'Find Middle of Linked List',
    topic: 'Linked Lists',
    description: 'Find middle element in single pass using two pointers',
    explanation: '''
Finding the middle element without knowing length.

**Naive Approach:**
1. Count all nodes (O(n))
2. Traverse to n/2 (O(n))
Total: 2 passes

**Optimized (Two Pointers):**
• Slow moves 1 step
• Fast moves 2 steps
• When fast reaches end, slow is at middle!

**Visual Example:**
1 → 2 → 3 → 4 → 5

Step 1: slow=1, fast=1
Step 2: slow=2, fast=3
Step 3: slow=3, fast=5 (end)
Middle = 3 ✓

**For Even Length:**
1 → 2 → 3 → 4
slow=2 (first middle) or slow=3 (second middle)
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

// Method 1: Two Pointer (Single Pass) - O(n) time, O(1) space
struct Node* findMiddle(struct Node* head) {
    if (head == NULL) return NULL;
    
    struct Node* slow = head;
    struct Node* fast = head;
    
    // Fast moves 2 steps, slow moves 1 step
    while (fast != NULL && fast->next != NULL) {
        slow = slow->next;
        fast = fast->next->next;
    }
    
    return slow;  // Middle node
}

// Method 2: Get second middle for even length
struct Node* getSecondMiddle(struct Node* head) {
    if (head == NULL) return NULL;
    
    struct Node* slow = head;
    struct Node* fast = head;
    struct Node* prev = NULL;
    
    while (fast != NULL && fast->next != NULL) {
        prev = slow;
        slow = slow->next;
        fast = fast->next->next;
    }
    
    // For even length, prev points to first middle
    // slow points to second middle
    return slow;
}

// Method 3: Delete middle node
void deleteMiddle(struct Node** head) {
    if (*head == NULL || (*head)->next == NULL) {
        free(*head);
        *head = NULL;
        return;
    }
    
    struct Node* slow = *head;
    struct Node* fast = *head;
    struct Node* prev = NULL;
    
    while (fast != NULL && fast->next != NULL) {
        prev = slow;
        slow = slow->next;
        fast = fast->next->next;
    }
    
    prev->next = slow->next;
    printf("Deleted middle node: %d\\n", slow->data);
    free(slow);
}

// Count method for comparison
int getMiddleByCount(struct Node* head) {
    int count = 0;
    struct Node* temp = head;
    
    // Count nodes
    while (temp) {
        count++;
        temp = temp->next;
    }
    
    // Go to middle
    temp = head;
    for (int i = 0; i < count / 2; i++) {
        temp = temp->next;
    }
    
    return temp->data;
}

void display(struct Node* head) {
    while (head) {
        printf("%d -> ", head->data);
        head = head->next;
    }
    printf("NULL\\n");
}

int main() {
    // Odd length: 1 -> 2 -> 3 -> 4 -> 5
    struct Node* head1 = createNode(1);
    head1->next = createNode(2);
    head1->next->next = createNode(3);
    head1->next->next->next = createNode(4);
    head1->next->next->next->next = createNode(5);
    
    printf("Odd length list: ");
    display(head1);
    printf("Middle element: %d\\n\\n", findMiddle(head1)->data);
    
    // Even length: 1 -> 2 -> 3 -> 4 -> 5 -> 6
    struct Node* head2 = createNode(1);
    head2->next = createNode(2);
    head2->next->next = createNode(3);
    head2->next->next->next = createNode(4);
    head2->next->next->next->next = createNode(5);
    head2->next->next->next->next->next = createNode(6);
    
    printf("Even length list: ");
    display(head2);
    printf("Middle element: %d\\n\\n", findMiddle(head2)->data);
    
    // Delete middle
    printf("After deleting middle: ");
    deleteMiddle(&head1);
    display(head1);
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Two pointer technique avoids counting',
      'Fast pointer moves twice as fast',
      'When fast reaches end, slow is at middle',
      'Can delete middle in same traversal',
    ],
    iconName: 'center_focus_strong',
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

  // Stacks - Program 2: Balanced Parentheses
  DSProgram(
    id: 'stack_balanced',
    title: 'Balanced Parentheses Checker',
    topic: 'Stacks',
    description: 'Check if brackets are properly balanced using stack',
    explanation: '''
Check if (, {, [ are properly matched with ), }, ].

**Algorithm:**
1. Scan expression left to right
2. If opening bracket: Push to stack
3. If closing bracket: Pop and check if matching
4. At end: Stack should be empty

**Examples:**
{()[]} → Balanced ✓
{[(])} → Not balanced ✗ (Mismatch)
{[} → Not balanced ✗ (Missing closing)

**Visual Trace for {[()]}:**
Read { → Push → Stack: [{]
Read [ → Push → Stack: [{, []
Read ( → Push → Stack: [{, [, (]
Read ) → Pop ( → Match! Stack: [{, []
Read ] → Pop [ → Match! Stack: [{]
Read } → Pop { → Match! Stack: []
Empty stack → Balanced!
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_SIZE 100

struct Stack {
    char items[MAX_SIZE];
    int top;
};

void init(struct Stack* s) {
    s->top = -1;
}

bool isEmpty(struct Stack* s) {
    return s->top == -1;
}

void push(struct Stack* s, char c) {
    s->items[++s->top] = c;
}

char pop(struct Stack* s) {
    if (isEmpty(s)) return '\\0';
    return s->items[s->top--];
}

// Check if brackets match
bool isMatchingPair(char opening, char closing) {
    return (opening == '(' && closing == ')') ||
           (opening == '{' && closing == '}') ||
           (opening == '[' && closing == ']');
}

// Check if expression has balanced brackets
bool isBalanced(char* expr) {
    struct Stack stack;
    init(&stack);
    
    for (int i = 0; expr[i] != '\\0'; i++) {
        char c = expr[i];
        
        // Push opening brackets
        if (c == '(' || c == '{' || c == '[') {
            push(&stack, c);
        }
        // Check closing brackets
        else if (c == ')' || c == '}' || c == ']') {
            if (isEmpty(&stack)) {
                return false;  // No matching opening
            }
            
            char top = pop(&stack);
            if (!isMatchingPair(top, c)) {
                return false;  // Wrong match
            }
        }
    }
    
    return isEmpty(&stack);  // Should be empty at end
}

// Count nested depth
int maxNestingDepth(char* expr) {
    int maxDepth = 0;
    int currentDepth = 0;
    
    for (int i = 0; expr[i] != '\\0'; i++) {
        if (expr[i] == '(' || expr[i] == '{' || expr[i] == '[') {
            currentDepth++;
            if (currentDepth > maxDepth) {
                maxDepth = currentDepth;
            }
        } else if (expr[i] == ')' || expr[i] == '}' || expr[i] == ']') {
            currentDepth--;
        }
    }
    
    return maxDepth;
}

int main() {
    char* tests[] = {
        "{[()]}",
        "((()))",
        "{[(])}",
        "{hello}[world]()",
        "(()",
        ""
    };
    
    int n = sizeof(tests) / sizeof(tests[0]);
    
    for (int i = 0; i < n; i++) {
        printf("\"%s\" -> %s\\n", tests[i], 
               isBalanced(tests[i]) ? "Balanced" : "Not Balanced");
    }
    
    printf("\\nMax nesting depth of '{[()]}': %d\\n", 
           maxNestingDepth("{[()]}"));
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Push opening brackets, pop for closing',
      'Check if popped bracket matches current',
      'Stack should be empty at end',
      'Classic stack application',
    ],
    iconName: 'check_circle',
    colorValue: 0xFFFFB347,
  ),

  // Stacks - Program 3: Infix to Postfix
  DSProgram(
    id: 'stack_infix_postfix',
    title: 'Infix to Postfix Conversion',
    topic: 'Stacks',
    description: 'Convert infix expression to postfix using stack',
    explanation: '''
Convert A+B*C to ABC*+ (Postfix/Reverse Polish Notation)

**Infix:** Operator between operands (A + B)
**Postfix:** Operator after operands (A B +)

**Why Postfix?**
• No parentheses needed
• Easy to evaluate with stack
• Used in calculators and compilers

**Algorithm:**
1. If operand → Add to output
2. If '(' → Push to stack
3. If ')' → Pop until '(' found
4. If operator:
   - Pop higher/equal precedence operators
   - Push current operator
5. Pop remaining operators

**Precedence:** * / > + -

**Example: A+B*C**
A → Output: A
+ → Stack: [+]
B → Output: AB
* → Stack: [+, *]  (* has higher precedence)
C → Output: ABC
Pop all: Output: ABC*+
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SIZE 100

struct Stack {
    char items[MAX_SIZE];
    int top;
};

void init(struct Stack* s) { s->top = -1; }
int isEmpty(struct Stack* s) { return s->top == -1; }
void push(struct Stack* s, char c) { s->items[++s->top] = c; }
char pop(struct Stack* s) { return isEmpty(s) ? '\\0' : s->items[s->top--]; }
char peek(struct Stack* s) { return isEmpty(s) ? '\\0' : s->items[s->top]; }

// Get operator precedence
int precedence(char op) {
    switch(op) {
        case '+': case '-': return 1;
        case '*': case '/': return 2;
        case '^': return 3;
        default: return 0;
    }
}

// Check if character is operator
int isOperator(char c) {
    return c == '+' || c == '-' || c == '*' || c == '/' || c == '^';
}

// Convert infix to postfix
void infixToPostfix(char* infix, char* postfix) {
    struct Stack stack;
    init(&stack);
    int j = 0;
    
    for (int i = 0; infix[i] != '\\0'; i++) {
        char c = infix[i];
        
        // Skip spaces
        if (c == ' ') continue;
        
        // Operand: Add to output
        if (isalnum(c)) {
            postfix[j++] = c;
        }
        // Opening parenthesis: Push
        else if (c == '(') {
            push(&stack, c);
        }
        // Closing parenthesis: Pop until '('
        else if (c == ')') {
            while (!isEmpty(&stack) && peek(&stack) != '(') {
                postfix[j++] = pop(&stack);
            }
            pop(&stack);  // Remove '('
        }
        // Operator
        else if (isOperator(c)) {
            while (!isEmpty(&stack) && 
                   peek(&stack) != '(' &&
                   precedence(peek(&stack)) >= precedence(c)) {
                postfix[j++] = pop(&stack);
            }
            push(&stack, c);
        }
    }
    
    // Pop remaining operators
    while (!isEmpty(&stack)) {
        postfix[j++] = pop(&stack);
    }
    
    postfix[j] = '\\0';
}

// Evaluate postfix expression
int evaluatePostfix(char* postfix) {
    int numStack[MAX_SIZE];
    int top = -1;
    
    for (int i = 0; postfix[i] != '\\0'; i++) {
        char c = postfix[i];
        
        if (isdigit(c)) {
            numStack[++top] = c - '0';
        } else if (isOperator(c)) {
            int b = numStack[top--];
            int a = numStack[top--];
            
            switch(c) {
                case '+': numStack[++top] = a + b; break;
                case '-': numStack[++top] = a - b; break;
                case '*': numStack[++top] = a * b; break;
                case '/': numStack[++top] = a / b; break;
            }
        }
    }
    
    return numStack[top];
}

int main() {
    char infix[] = "A+B*C-D/E";
    char postfix[MAX_SIZE];
    
    infixToPostfix(infix, postfix);
    printf("Infix:   %s\\n", infix);
    printf("Postfix: %s\\n\\n", postfix);
    
    // Evaluate numeric expression
    char expr[] = "2+3*4-6/2";
    char postfixNum[MAX_SIZE];
    infixToPostfix(expr, postfixNum);
    
    printf("Expression: %s\\n", expr);
    printf("Postfix:    %s\\n", postfixNum);
    printf("Result:     %d\\n", evaluatePostfix(postfixNum));
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Operands go directly to output',
      'Operators stack based on precedence',
      'Postfix is easier to evaluate',
      'Used in compilers for expression parsing',
    ],
    iconName: 'calculate',
    colorValue: 0xFFFFB347,
  ),

  // Stacks - Program 4: Stack using Linked List
  DSProgram(
    id: 'stack_linked_list',
    title: 'Stack using Linked List',
    topic: 'Stacks',
    description: 'Dynamic stack implementation without size limit',
    explanation: '''
Implementing stack using linked list provides dynamic sizing.

**Array Stack Limitation:**
• Fixed size (MAX_SIZE)
• Overflow possible
• Memory wastage if not full

**Linked List Stack:**
• Dynamic size
• No overflow (until memory full)
• No memory wastage

**Structure:**
Top → [30] → [20] → [10] → NULL

**Operations:**
• Push: Insert at beginning (O(1))
• Pop: Delete from beginning (O(1))
• No need to shift elements!

**Trade-off:**
• Extra memory for pointers
• Not cache-friendly
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Node structure
struct Node {
    int data;
    struct Node* next;
};

// Stack structure
struct Stack {
    struct Node* top;
    int count;
};

// Initialize stack
void init(struct Stack* s) {
    s->top = NULL;
    s->count = 0;
}

bool isEmpty(struct Stack* s) {
    return s->top == NULL;
}

// Push - O(1)
void push(struct Stack* s, int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) {
        printf("Memory allocation failed!\\n");
        return;
    }
    
    newNode->data = data;
    newNode->next = s->top;
    s->top = newNode;
    s->count++;
    printf("Pushed: %d\\n", data);
}

// Pop - O(1)
int pop(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack Underflow!\\n");
        return -1;
    }
    
    struct Node* temp = s->top;
    int data = temp->data;
    s->top = s->top->next;
    free(temp);
    s->count--;
    return data;
}

// Peek - O(1)
int peek(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\\n");
        return -1;
    }
    return s->top->data;
}

// Get size - O(1)
int size(struct Stack* s) {
    return s->count;
}

// Display stack
void display(struct Stack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\\n");
        return;
    }
    
    printf("Stack (top to bottom): ");
    struct Node* temp = s->top;
    while (temp) {
        printf("%d ", temp->data);
        temp = temp->next;
    }
    printf("\\n");
}

// Free all memory
void freeStack(struct Stack* s) {
    while (!isEmpty(s)) {
        pop(s);
    }
    printf("Stack memory freed\\n");
}

int main() {
    struct Stack stack;
    init(&stack);
    
    push(&stack, 10);
    push(&stack, 20);
    push(&stack, 30);
    push(&stack, 40);
    
    display(&stack);
    printf("Size: %d\\n", size(&stack));
    printf("Top: %d\\n\\n", peek(&stack));
    
    printf("Popped: %d\\n", pop(&stack));
    printf("Popped: %d\\n", pop(&stack));
    
    display(&stack);
    
    freeStack(&stack);
    
    return 0;
}''',
    timeComplexity: 'Push: O(1), Pop: O(1), Peek: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'No fixed size limit',
      'Insert and delete at head only',
      'No overflow (memory permitting)',
      'Extra pointer overhead per element',
    ],
    iconName: 'stacked_line_chart',
    colorValue: 0xFFFFB347,
  ),

  // Stacks - Program 5: Min Stack
  DSProgram(
    id: 'stack_min',
    title: 'Min Stack - O(1) Minimum',
    topic: 'Stacks',
    description: 'Stack with O(1) getMin operation',
    explanation: '''
Special stack that returns minimum element in O(1) time.

**Problem:** Normal stack needs O(n) to find minimum.

**Solution - Two Stacks:**
• Main stack: Stores all elements
• Min stack: Tracks minimum at each level

**Example:**
Push 5: Main[5], Min[5]
Push 3: Main[5,3], Min[5,3]
Push 7: Main[5,3,7], Min[5,3,3]
Push 2: Main[5,3,7,2], Min[5,3,3,2]

getMin() = top of Min stack = 2 (O(1)!)

Pop: Main[5,3,7], Min[5,3,3]
getMin() = 3 ✓

**Alternative (Space Optimized):**
Store 2*x - min when x < current min.
Recovers previous min during pop.
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#define MAX_SIZE 100

// Min Stack using auxiliary stack
struct MinStack {
    int mainStack[MAX_SIZE];
    int minStack[MAX_SIZE];
    int top;
};

void init(struct MinStack* s) {
    s->top = -1;
}

int isEmpty(struct MinStack* s) {
    return s->top == -1;
}

int isFull(struct MinStack* s) {
    return s->top == MAX_SIZE - 1;
}

// Push with min tracking
void push(struct MinStack* s, int value) {
    if (isFull(s)) {
        printf("Stack Overflow!\\n");
        return;
    }
    
    s->mainStack[++s->top] = value;
    
    // Update min stack
    if (s->top == 0) {
        s->minStack[s->top] = value;
    } else {
        int currentMin = s->minStack[s->top - 1];
        s->minStack[s->top] = (value < currentMin) ? value : currentMin;
    }
    
    printf("Pushed: %d (Current min: %d)\\n", value, s->minStack[s->top]);
}

// Pop
int pop(struct MinStack* s) {
    if (isEmpty(s)) {
        printf("Stack Underflow!\\n");
        return INT_MIN;
    }
    return s->mainStack[s->top--];
}

// Get top element
int top(struct MinStack* s) {
    if (isEmpty(s)) return INT_MIN;
    return s->mainStack[s->top];
}

// Get minimum in O(1)!
int getMin(struct MinStack* s) {
    if (isEmpty(s)) return INT_MIN;
    return s->minStack[s->top];
}

// Display
void display(struct MinStack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\\n");
        return;
    }
    
    printf("Stack: ");
    for (int i = 0; i <= s->top; i++) {
        printf("%d ", s->mainStack[i]);
    }
    printf("| Min: %d\\n", getMin(s));
}

int main() {
    struct MinStack stack;
    init(&stack);
    
    push(&stack, 5);
    push(&stack, 3);
    push(&stack, 7);
    push(&stack, 2);
    push(&stack, 8);
    
    display(&stack);
    printf("\\nMinimum: %d\\n\\n", getMin(&stack));
    
    printf("Pop: %d\\n", pop(&stack));
    printf("Minimum after pop: %d\\n\\n", getMin(&stack));
    
    printf("Pop: %d\\n", pop(&stack));
    printf("Minimum after pop: %d\\n\\n", getMin(&stack));
    
    display(&stack);
    
    return 0;
}''',
    timeComplexity: 'All operations: O(1)',
    spaceComplexity: 'O(n) for auxiliary stack',
    keyPoints: [
      'Auxiliary stack tracks minimums',
      'getMin() in O(1) time',
      'Space can be optimized with math trick',
      'Common interview question',
    ],
    iconName: 'trending_down',
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

  // Queues - Program 2: Priority Queue
  DSProgram(
    id: 'queue_priority',
    title: 'Priority Queue',
    topic: 'Queues',
    description: 'Queue where elements are dequeued based on priority',
    explanation: '''
Elements with higher priority are served before lower priority.

**Types:**
• Max Priority Queue: Largest element first
• Min Priority Queue: Smallest element first

**Implementation Methods:**
1. Unsorted Array: O(1) insert, O(n) delete
2. Sorted Array: O(n) insert, O(1) delete
3. Heap: O(log n) both (most efficient)

**Example (Max Priority):**
Insert 3,1,4,1,5,9,2,6
Dequeue order: 9,6,5,4,3,2,1,1

**Real-world Uses:**
• CPU scheduling
• Dijkstra's algorithm
• Huffman coding
• Hospital emergency rooms
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 20

// Priority Queue using sorted array (descending order)
struct PriorityQueue {
    int items[MAX_SIZE];
    int size;
};

void init(struct PriorityQueue* pq) {
    pq->size = 0;
}

int isEmpty(struct PriorityQueue* pq) {
    return pq->size == 0;
}

int isFull(struct PriorityQueue* pq) {
    return pq->size == MAX_SIZE;
}

// Insert maintaining sorted order - O(n)
void enqueue(struct PriorityQueue* pq, int priority) {
    if (isFull(pq)) {
        printf("Queue is full!\\n");
        return;
    }
    
    // Find correct position
    int i = pq->size - 1;
    while (i >= 0 && pq->items[i] < priority) {
        pq->items[i + 1] = pq->items[i];
        i--;
    }
    
    pq->items[i + 1] = priority;
    pq->size++;
    printf("Enqueued: %d\\n", priority);
}

// Dequeue highest priority - O(1)
int dequeue(struct PriorityQueue* pq) {
    if (isEmpty(pq)) {
        printf("Queue is empty!\\n");
        return -1;
    }
    
    int highest = pq->items[0];
    
    // Shift elements
    for (int i = 0; i < pq->size - 1; i++) {
        pq->items[i] = pq->items[i + 1];
    }
    pq->size--;
    
    return highest;
}

// Peek highest priority - O(1)
int peek(struct PriorityQueue* pq) {
    if (isEmpty(pq)) return -1;
    return pq->items[0];
}

void display(struct PriorityQueue* pq) {
    if (isEmpty(pq)) {
        printf("Queue is empty!\\n");
        return;
    }
    
    printf("Priority Queue: ");
    for (int i = 0; i < pq->size; i++) {
        printf("%d ", pq->items[i]);
    }
    printf("\\n");
}

int main() {
    struct PriorityQueue pq;
    init(&pq);
    
    enqueue(&pq, 3);
    enqueue(&pq, 1);
    enqueue(&pq, 4);
    enqueue(&pq, 1);
    enqueue(&pq, 5);
    enqueue(&pq, 9);
    
    display(&pq);
    printf("Highest priority: %d\\n\\n", peek(&pq));
    
    printf("Dequeue order: ");
    while (!isEmpty(&pq)) {
        printf("%d ", dequeue(&pq));
    }
    printf("\\n");
    
    return 0;
}''',
    timeComplexity: 'Enqueue: O(n), Dequeue: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Elements served by priority not order',
      'Heap implementation is most efficient',
      'Used in scheduling algorithms',
      'Sorted array trades insert for delete time',
    ],
    iconName: 'priority_high',
    colorValue: 0xFF9B59B6,
  ),

  // Queues - Program 3: Queue using Linked List
  DSProgram(
    id: 'queue_linked_list',
    title: 'Queue using Linked List',
    topic: 'Queues',
    description: 'Dynamic queue with no size limit',
    explanation: '''
Linked list queue eliminates fixed size limitation.

**Structure:**
Front → [10] → [20] → [30] → NULL ← Rear

**Operations:**
• Enqueue: Add at rear (O(1) with tail pointer)
• Dequeue: Remove from front (O(1))

**Advantages:**
• Dynamic size
• No overflow (memory permitting)
• No need for circular logic

**Disadvantages:**
• Extra pointer overhead
• Not cache-friendly
• More complex implementation
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

struct Node {
    int data;
    struct Node* next;
};

struct Queue {
    struct Node* front;
    struct Node* rear;
    int count;
};

void init(struct Queue* q) {
    q->front = q->rear = NULL;
    q->count = 0;
}

bool isEmpty(struct Queue* q) {
    return q->front == NULL;
}

// Enqueue - O(1)
void enqueue(struct Queue* q, int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    
    if (isEmpty(q)) {
        q->front = q->rear = newNode;
    } else {
        q->rear->next = newNode;
        q->rear = newNode;
    }
    q->count++;
    printf("Enqueued: %d\\n", data);
}

// Dequeue - O(1)
int dequeue(struct Queue* q) {
    if (isEmpty(q)) {
        printf("Queue Underflow!\\n");
        return -1;
    }
    
    struct Node* temp = q->front;
    int data = temp->data;
    q->front = q->front->next;
    
    if (q->front == NULL) {
        q->rear = NULL;
    }
    
    free(temp);
    q->count--;
    return data;
}

int getFront(struct Queue* q) {
    if (isEmpty(q)) return -1;
    return q->front->data;
}

int getRear(struct Queue* q) {
    if (isEmpty(q)) return -1;
    return q->rear->data;
}

int size(struct Queue* q) {
    return q->count;
}

void display(struct Queue* q) {
    if (isEmpty(q)) {
        printf("Queue is empty!\\n");
        return;
    }
    
    printf("Queue: ");
    struct Node* temp = q->front;
    while (temp) {
        printf("%d ", temp->data);
        temp = temp->next;
    }
    printf("\\n");
}

int main() {
    struct Queue queue;
    init(&queue);
    
    enqueue(&queue, 10);
    enqueue(&queue, 20);
    enqueue(&queue, 30);
    enqueue(&queue, 40);
    
    display(&queue);
    printf("Front: %d, Rear: %d, Size: %d\\n\\n", 
           getFront(&queue), getRear(&queue), size(&queue));
    
    printf("Dequeued: %d\\n", dequeue(&queue));
    printf("Dequeued: %d\\n", dequeue(&queue));
    
    display(&queue);
    
    return 0;
}''',
    timeComplexity: 'Enqueue: O(1), Dequeue: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Uses both front and rear pointers',
      'No circular array logic needed',
      'Dynamic sizing',
      'Extra pointer overhead per element',
    ],
    iconName: 'linear_scale',
    colorValue: 0xFF9B59B6,
  ),

  // Queues - Program 4: Deque (Double-ended Queue)
  DSProgram(
    id: 'queue_deque',
    title: 'Deque - Double-Ended Queue',
    topic: 'Queues',
    description: 'Queue with insertion and deletion at both ends',
    explanation: '''
Deque allows operations at both front and rear.

**Operations:**
• insertFront(): Add at front
• insertRear(): Add at rear
• deleteFront(): Remove from front
• deleteRear(): Remove from rear

**Types:**
• Input-restricted: Insert at one end only
• Output-restricted: Delete at one end only

**Uses:**
• Sliding window problems
• Palindrome checking
• Undo/Redo with history limit
• A-Steal job scheduling

**Implementation:**
Using circular array for O(1) operations.
''',
    code: '''#include <stdio.h>
#include <stdbool.h>

#define MAX_SIZE 10

struct Deque {
    int items[MAX_SIZE];
    int front;
    int rear;
    int count;
};

void init(struct Deque* dq) {
    dq->front = 0;
    dq->rear = -1;
    dq->count = 0;
}

bool isEmpty(struct Deque* dq) {
    return dq->count == 0;
}

bool isFull(struct Deque* dq) {
    return dq->count == MAX_SIZE;
}

// Insert at front - O(1)
void insertFront(struct Deque* dq, int value) {
    if (isFull(dq)) {
        printf("Deque is full!\\n");
        return;
    }
    
    dq->front = (dq->front - 1 + MAX_SIZE) % MAX_SIZE;
    dq->items[dq->front] = value;
    dq->count++;
    printf("Inserted %d at front\\n", value);
}

// Insert at rear - O(1)
void insertRear(struct Deque* dq, int value) {
    if (isFull(dq)) {
        printf("Deque is full!\\n");
        return;
    }
    
    dq->rear = (dq->rear + 1) % MAX_SIZE;
    dq->items[dq->rear] = value;
    dq->count++;
    printf("Inserted %d at rear\\n", value);
}

// Delete from front - O(1)
int deleteFront(struct Deque* dq) {
    if (isEmpty(dq)) {
        printf("Deque is empty!\\n");
        return -1;
    }
    
    int value = dq->items[dq->front];
    dq->front = (dq->front + 1) % MAX_SIZE;
    dq->count--;
    return value;
}

// Delete from rear - O(1)
int deleteRear(struct Deque* dq) {
    if (isEmpty(dq)) {
        printf("Deque is empty!\\n");
        return -1;
    }
    
    int value = dq->items[dq->rear];
    dq->rear = (dq->rear - 1 + MAX_SIZE) % MAX_SIZE;
    dq->count--;
    return value;
}

int getFront(struct Deque* dq) {
    if (isEmpty(dq)) return -1;
    return dq->items[dq->front];
}

int getRear(struct Deque* dq) {
    if (isEmpty(dq)) return -1;
    return dq->items[dq->rear];
}

void display(struct Deque* dq) {
    if (isEmpty(dq)) {
        printf("Deque is empty!\\n");
        return;
    }
    
    printf("Deque: ");
    int i = dq->front;
    for (int j = 0; j < dq->count; j++) {
        printf("%d ", dq->items[i]);
        i = (i + 1) % MAX_SIZE;
    }
    printf("\\n");
}

int main() {
    struct Deque dq;
    init(&dq);
    
    insertRear(&dq, 10);
    insertRear(&dq, 20);
    insertFront(&dq, 5);
    insertFront(&dq, 1);
    insertRear(&dq, 30);
    
    display(&dq);
    printf("Front: %d, Rear: %d\\n\\n", getFront(&dq), getRear(&dq));
    
    printf("Deleted from front: %d\\n", deleteFront(&dq));
    printf("Deleted from rear: %d\\n", deleteRear(&dq));
    
    display(&dq);
    
    return 0;
}''',
    timeComplexity: 'All operations: O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Insert and delete at both ends',
      'Circular array for efficient implementation',
      'Can act as stack or queue',
      'Used in sliding window algorithms',
    ],
    iconName: 'swap_horizontal_circle',
    colorValue: 0xFF9B59B6,
  ),

  // Queues - Program 5: Queue using Two Stacks
  DSProgram(
    id: 'queue_two_stacks',
    title: 'Queue using Two Stacks',
    topic: 'Queues',
    description: 'Implement queue behavior using two stacks',
    explanation: '''
Implement FIFO queue using only LIFO stacks.

**Method:**
• Stack1: For enqueue operations
• Stack2: For dequeue operations

**Algorithm:**
Enqueue: Push to Stack1

Dequeue:
1. If Stack2 empty, transfer all from Stack1
2. Pop from Stack2

**Example:**
Enqueue 1,2,3: Stack1 = [1,2,3], Stack2 = []

Dequeue:
- Transfer: Stack1 = [], Stack2 = [3,2,1]
- Pop Stack2: Returns 1 ✓

**Complexity:**
• Enqueue: O(1)
• Dequeue: Amortized O(1)
''',
    code: '''#include <stdio.h>
#include <stdbool.h>

#define MAX_SIZE 20

struct Stack {
    int items[MAX_SIZE];
    int top;
};

void initStack(struct Stack* s) { s->top = -1; }
bool isStackEmpty(struct Stack* s) { return s->top == -1; }
bool isStackFull(struct Stack* s) { return s->top == MAX_SIZE - 1; }
void push(struct Stack* s, int x) { s->items[++s->top] = x; }
int pop(struct Stack* s) { return isStackEmpty(s) ? -1 : s->items[s->top--]; }
int peek(struct Stack* s) { return isStackEmpty(s) ? -1 : s->items[s->top]; }

// Queue using two stacks
struct QueueFromStacks {
    struct Stack stack1;  // For enqueue
    struct Stack stack2;  // For dequeue
};

void init(struct QueueFromStacks* q) {
    initStack(&q->stack1);
    initStack(&q->stack2);
}

bool isEmpty(struct QueueFromStacks* q) {
    return isStackEmpty(&q->stack1) && isStackEmpty(&q->stack2);
}

// Enqueue - O(1)
void enqueue(struct QueueFromStacks* q, int value) {
    push(&q->stack1, value);
    printf("Enqueued: %d\\n", value);
}

// Transfer elements from stack1 to stack2
void transfer(struct QueueFromStacks* q) {
    while (!isStackEmpty(&q->stack1)) {
        push(&q->stack2, pop(&q->stack1));
    }
}

// Dequeue - Amortized O(1)
int dequeue(struct QueueFromStacks* q) {
    if (isEmpty(q)) {
        printf("Queue is empty!\\n");
        return -1;
    }
    
    // Transfer if stack2 is empty
    if (isStackEmpty(&q->stack2)) {
        transfer(q);
    }
    
    return pop(&q->stack2);
}

// Get front element
int getFront(struct QueueFromStacks* q) {
    if (isEmpty(q)) return -1;
    
    if (isStackEmpty(&q->stack2)) {
        transfer(q);
    }
    
    return peek(&q->stack2);
}

void display(struct QueueFromStacks* q) {
    printf("Stack1 (enqueue): ");
    for (int i = 0; i <= q->stack1.top; i++) {
        printf("%d ", q->stack1.items[i]);
    }
    printf("\\nStack2 (dequeue): ");
    for (int i = q->stack2.top; i >= 0; i--) {
        printf("%d ", q->stack2.items[i]);
    }
    printf("\\n");
}

int main() {
    struct QueueFromStacks queue;
    init(&queue);
    
    enqueue(&queue, 1);
    enqueue(&queue, 2);
    enqueue(&queue, 3);
    printf("\\n");
    display(&queue);
    
    printf("\\nDequeue: %d\\n", dequeue(&queue));
    printf("Front: %d\\n\\n", getFront(&queue));
    
    enqueue(&queue, 4);
    enqueue(&queue, 5);
    
    display(&queue);
    
    printf("\\nDequeue all: ");
    while (!isEmpty(&queue)) {
        printf("%d ", dequeue(&queue));
    }
    printf("\\n");
    
    return 0;
}''',
    timeComplexity: 'Enqueue: O(1), Dequeue: Amortized O(1)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Uses two stacks to simulate queue',
      'Lazy transfer on dequeue',
      'Amortized O(1) complexity',
      'Common interview question',
    ],
    iconName: 'compare_arrows',
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

  // Searching - Program 2: Linear Search
  DSProgram(
    id: 'linear_search',
    title: 'Linear Search Algorithm',
    topic: 'Searching',
    description: 'Simple sequential search through array',
    explanation: '''
Linear search checks each element one by one until found.

**How it works:**
1. Start from first element
2. Compare with target
3. If match, return index
4. If not, move to next
5. Repeat until found or end

**When to use:**
• Unsorted data
• Small arrays
• Single search needed
• Linked lists

**Optimizations:**
• Sentinel search (reduce comparisons)
• Move to front (for repeated searches)
• Transposition (swap with previous)
''',
    code: '''#include <stdio.h>

// Basic Linear Search - O(n)
int linearSearch(int arr[], int n, int target) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == target) {
            return i;  // Found
        }
    }
    return -1;  // Not found
}

// Sentinel Linear Search - Fewer comparisons
int sentinelSearch(int arr[], int n, int target) {
    int last = arr[n - 1];  // Save last element
    arr[n - 1] = target;    // Set sentinel
    
    int i = 0;
    while (arr[i] != target) {
        i++;
    }
    
    arr[n - 1] = last;      // Restore last element
    
    if (i < n - 1 || arr[n - 1] == target) {
        return i;
    }
    return -1;
}

// Find all occurrences
void findAllOccurrences(int arr[], int n, int target) {
    printf("Occurrences of %d at indices: ", target);
    int found = 0;
    
    for (int i = 0; i < n; i++) {
        if (arr[i] == target) {
            printf("%d ", i);
            found++;
        }
    }
    
    if (found == 0) {
        printf("None");
    }
    printf(" (Count: %d)\\n", found);
}

// Find min and max in single pass
void findMinMax(int arr[], int n, int* min, int* max) {
    *min = *max = arr[0];
    
    for (int i = 1; i < n; i++) {
        if (arr[i] < *min) *min = arr[i];
        if (arr[i] > *max) *max = arr[i];
    }
}

int main() {
    int arr[] = {10, 20, 30, 20, 40, 50, 20, 60};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 20;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\n");
    
    // Basic search
    int index = linearSearch(arr, n, target);
    if (index != -1) {
        printf("First occurrence of %d at index %d\\n", target, index);
    }
    
    // Find all
    findAllOccurrences(arr, n, target);
    
    // Min/Max
    int min, max;
    findMinMax(arr, n, &min, &max);
    printf("\\nMin: %d, Max: %d\\n", min, max);
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Works on unsorted arrays',
      'Simple to implement',
      'Best for small datasets',
      'Sentinel optimization reduces comparisons',
    ],
    iconName: 'format_list_numbered',
    colorValue: 0xFF3498DB,
  ),

  // Searching - Program 3: Jump Search
  DSProgram(
    id: 'jump_search',
    title: 'Jump Search Algorithm',
    topic: 'Searching',
    description: 'Search by jumping fixed steps in sorted array',
    explanation: '''
Jump search is between linear and binary search.

**Optimal Jump Size:** √n

**How it works:**
1. Jump √n elements at a time
2. When arr[jump] > target, stop
3. Linear search in previous block

**Example (target = 55):**
[0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
n=10, jump=√10≈3

Jump 1: index 3 → 30 < 55, jump
Jump 2: index 6 → 60 > 55, stop!
Linear search [40, 50, 60] → Found 50 at index 5

**Better than linear, simpler than binary!**
''',
    code: '''#include <stdio.h>
#include <math.h>

int jumpSearch(int arr[], int n, int target) {
    int step = (int)sqrt(n);  // Optimal jump size
    int prev = 0;
    
    // Find block where element is present
    while (arr[(step < n ? step : n) - 1] < target) {
        prev = step;
        step += (int)sqrt(n);
        
        if (prev >= n) {
            return -1;  // Element not present
        }
    }
    
    // Linear search in identified block
    while (arr[prev] < target) {
        prev++;
        
        if (prev == (step < n ? step : n)) {
            return -1;
        }
    }
    
    if (arr[prev] == target) {
        return prev;
    }
    
    return -1;
}

// Jump search with step tracking for visualization
int jumpSearchVisualize(int arr[], int n, int target) {
    int step = (int)sqrt(n);
    int prev = 0;
    int jumpCount = 0;
    int linearCount = 0;
    
    printf("Array size: %d, Jump step: %d\\n\\n", n, step);
    
    // Jump phase
    while (arr[(step < n ? step : n) - 1] < target) {
        jumpCount++;
        printf("Jump %d: index %d, value %d\\n", jumpCount, step - 1, arr[step - 1]);
        prev = step;
        step += (int)sqrt(n);
        
        if (prev >= n) return -1;
    }
    printf("\\nStopped at block starting at index %d\\n", prev);
    
    // Linear phase
    printf("\\nLinear search in block:\\n");
    while (arr[prev] < target) {
        linearCount++;
        printf("Check index %d: %d\\n", prev, arr[prev]);
        prev++;
        if (prev == (step < n ? step : n)) return -1;
    }
    
    printf("\\nTotal: %d jumps + %d linear checks\\n", jumpCount, linearCount + 1);
    
    return (arr[prev] == target) ? prev : -1;
}

int main() {
    int arr[] = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 55;
    
    printf("Searching for %d:\\n\\n", target);
    
    int result = jumpSearchVisualize(arr, n, target);
    
    if (result != -1) {
        printf("\\nFound at index %d\\n", result);
    } else {
        printf("\\nNot found\\n");
    }
    
    return 0;
}''',
    timeComplexity: 'O(√n)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Works only on sorted arrays',
      'Optimal jump size is √n',
      'Better than linear, simpler than binary',
      'Good for systems with slow backward traversal',
    ],
    iconName: 'skip_next',
    colorValue: 0xFF3498DB,
  ),

  // Searching - Program 4: Interpolation Search
  DSProgram(
    id: 'interpolation_search',
    title: 'Interpolation Search',
    topic: 'Searching',
    description: 'Improved binary search for uniformly distributed data',
    explanation: '''
Like binary search but smarter position estimation.

**Binary search:** Always checks middle
**Interpolation:** Estimates position based on value

**Formula for probe position:**
pos = low + ((target - arr[low]) * (high - low)) / (arr[high] - arr[low])

**Example (target=23):**
[2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
Estimate: low=0, high=9
pos = 0 + ((23-2)*(9-0))/(91-2) = 0 + (21*9)/89 ≈ 2

Much closer to actual position (5) than middle (4)!

**Best for:** Uniformly distributed sorted data
**Worst case:** Non-uniform distribution
''',
    code: '''#include <stdio.h>

int interpolationSearch(int arr[], int n, int target) {
    int low = 0;
    int high = n - 1;
    
    while (low <= high && target >= arr[low] && target <= arr[high]) {
        if (low == high) {
            if (arr[low] == target) return low;
            return -1;
        }
        
        // Estimate position
        int pos = low + (((double)(high - low) / 
                         (arr[high] - arr[low])) * (target - arr[low]));
        
        printf("Checking position %d (value: %d)\\n", pos, arr[pos]);
        
        if (arr[pos] == target) {
            return pos;
        }
        
        if (arr[pos] < target) {
            low = pos + 1;
        } else {
            high = pos - 1;
        }
    }
    
    return -1;
}

// Compare with binary search
int binarySearch(int arr[], int n, int target) {
    int low = 0, high = n - 1;
    int steps = 0;
    
    while (low <= high) {
        int mid = low + (high - low) / 2;
        steps++;
        
        if (arr[mid] == target) {
            printf("Binary search: %d steps\\n", steps);
            return mid;
        }
        
        if (arr[mid] < target) low = mid + 1;
        else high = mid - 1;
    }
    
    printf("Binary search: %d steps\\n", steps);
    return -1;
}

int main() {
    // Uniformly distributed array
    int arr[] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 70;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\nSearching for %d:\\n\\n", target);
    
    printf("Interpolation search:\\n");
    int result = interpolationSearch(arr, n, target);
    
    if (result != -1) {
        printf("Found at index %d\\n\\n", result);
    }
    
    // Compare with binary
    binarySearch(arr, n, target);
    
    return 0;
}''',
    timeComplexity: 'Average: O(log log n), Worst: O(n)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Best for uniformly distributed data',
      'Estimates position based on value',
      'Faster than binary for uniform data',
      'Can degrade to O(n) for skewed data',
    ],
    iconName: 'insights',
    colorValue: 0xFF3498DB,
  ),

  // Searching - Program 5: Ternary Search
  DSProgram(
    id: 'ternary_search',
    title: 'Ternary Search',
    topic: 'Searching',
    description: 'Divide array into 3 parts for searching',
    explanation: '''
Like binary search but divides into 3 parts.

**How it works:**
1. Calculate mid1 = left + (right-left)/3
2. Calculate mid2 = right - (right-left)/3
3. Compare target with arr[mid1] and arr[mid2]
4. Eliminate 2/3 of search space

**Why 2 comparisons?**
Binary: 1 comparison → eliminate 1/2
Ternary: 2 comparisons → eliminate 2/3

**Comparison per element:**
Binary: log₂n comparisons
Ternary: 2*log₃n ≈ 1.26*log₂n comparisons

Binary is actually slightly better!
But ternary is useful for finding maxima.
''',
    code: '''#include <stdio.h>

// Ternary Search - Recursive
int ternarySearchRecursive(int arr[], int left, int right, int target) {
    if (right >= left) {
        int mid1 = left + (right - left) / 3;
        int mid2 = right - (right - left) / 3;
        
        printf("Checking mid1=%d (%d) and mid2=%d (%d)\\n", 
               mid1, arr[mid1], mid2, arr[mid2]);
        
        if (arr[mid1] == target) return mid1;
        if (arr[mid2] == target) return mid2;
        
        if (target < arr[mid1]) {
            // Search left third
            return ternarySearchRecursive(arr, left, mid1 - 1, target);
        } else if (target > arr[mid2]) {
            // Search right third
            return ternarySearchRecursive(arr, mid2 + 1, right, target);
        } else {
            // Search middle third
            return ternarySearchRecursive(arr, mid1 + 1, mid2 - 1, target);
        }
    }
    
    return -1;
}

// Ternary Search - Iterative
int ternarySearchIterative(int arr[], int n, int target) {
    int left = 0, right = n - 1;
    
    while (left <= right) {
        int mid1 = left + (right - left) / 3;
        int mid2 = right - (right - left) / 3;
        
        if (arr[mid1] == target) return mid1;
        if (arr[mid2] == target) return mid2;
        
        if (target < arr[mid1]) {
            right = mid1 - 1;
        } else if (target > arr[mid2]) {
            left = mid2 + 1;
        } else {
            left = mid1 + 1;
            right = mid2 - 1;
        }
    }
    
    return -1;
}

// Find maximum in unimodal array (main use case)
int findMaxUnimodal(int arr[], int left, int right) {
    if (left == right) return arr[left];
    
    if (right - left == 1) {
        return (arr[left] > arr[right]) ? arr[left] : arr[right];
    }
    
    int mid1 = left + (right - left) / 3;
    int mid2 = right - (right - left) / 3;
    
    if (arr[mid1] < arr[mid2]) {
        return findMaxUnimodal(arr, mid1, right);
    } else {
        return findMaxUnimodal(arr, left, mid2);
    }
}

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target = 7;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\nSearching for %d:\\n\\n", target);
    
    int result = ternarySearchRecursive(arr, 0, n - 1, target);
    
    if (result != -1) {
        printf("\\nFound at index %d\\n", result);
    }
    
    // Unimodal array example
    printf("\\n--- Finding max in unimodal array ---\\n");
    int unimodal[] = {1, 3, 5, 7, 9, 8, 6, 4, 2};
    int max = findMaxUnimodal(unimodal, 0, 8);
    printf("Maximum value: %d\\n", max);
    
    return 0;
}''',
    timeComplexity: 'O(log₃n)',
    spaceComplexity: 'O(1) iterative, O(log n) recursive',
    keyPoints: [
      'Divides array into 3 parts',
      'Actually slower than binary for value search',
      'Useful for finding maxima in unimodal arrays',
      'Used in optimization problems',
    ],
    iconName: 'filter_3',
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

  // Sorting - Program 2: Selection Sort
  DSProgram(
    id: 'selection_sort',
    title: 'Selection Sort Algorithm',
    topic: 'Sorting',
    description: 'Find minimum and place at correct position',
    explanation: '''
Selection Sort finds the minimum element and moves it to sorted portion.

**How it works:**
1. Find minimum in unsorted portion
2. Swap with first unsorted element
3. Expand sorted portion by 1
4. Repeat until done

**Visual Example:**
[64, 25, 12, 22, 11] - Find min=11
[11, 25, 12, 22, 64] - Swap 64↔11
[11, 12, 25, 22, 64] - Find min=12, swap
[11, 12, 22, 25, 64] - Find min=22, swap
[11, 12, 22, 25, 64] - Sorted!

**Characteristics:**
• Always O(n²) - doesn't adapt
• Minimum swaps (n-1)
• Not stable
• In-place
''',
    code: '''#include <stdio.h>

void selectionSort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        // Find minimum in unsorted portion
        int minIdx = i;
        
        for (int j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIdx]) {
                minIdx = j;
            }
        }
        
        // Swap minimum with first unsorted
        if (minIdx != i) {
            int temp = arr[i];
            arr[i] = arr[minIdx];
            arr[minIdx] = temp;
        }
        
        // Print pass
        printf("Pass %d: ", i + 1);
        for (int k = 0; k < n; k++) {
            printf("%d ", arr[k]);
        }
        printf("\\n");
    }
}

// Find k-th smallest element using selection idea
int kthSmallest(int arr[], int n, int k) {
    // Copy array to avoid modification
    int temp[n];
    for (int i = 0; i < n; i++) temp[i] = arr[i];
    
    // Do k passes of selection sort
    for (int i = 0; i < k; i++) {
        int minIdx = i;
        for (int j = i + 1; j < n; j++) {
            if (temp[j] < temp[minIdx]) minIdx = j;
        }
        int t = temp[i];
        temp[i] = temp[minIdx];
        temp[minIdx] = t;
    }
    
    return temp[k - 1];
}

void printArray(int arr[], int n) {
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n");
}

int main() {
    int arr[] = {64, 25, 12, 22, 11};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    printf("Original: ");
    printArray(arr, n);
    printf("\\n");
    
    selectionSort(arr, n);
    
    printf("\\nSorted: ");
    printArray(arr, n);
    
    // K-th smallest
    int arr2[] = {7, 10, 4, 3, 20, 15};
    printf("\\n3rd smallest in [7,10,4,3,20,15]: %d\\n", 
           kthSmallest(arr2, 6, 3));
    
    return 0;
}''',
    timeComplexity: 'O(n²) always',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Finds minimum and swaps to front',
      'Only n-1 swaps total',
      'Not stable (may reorder equals)',
      'Good when swaps are expensive',
    ],
    iconName: 'low_priority',
    colorValue: 0xFFE74C3C,
  ),

  // Sorting - Program 3: Insertion Sort
  DSProgram(
    id: 'insertion_sort',
    title: 'Insertion Sort Algorithm',
    topic: 'Sorting',
    description: 'Build sorted array one element at a time',
    explanation: '''
Like sorting playing cards in your hand.

**How it works:**
1. Pick element from unsorted portion
2. Find correct position in sorted portion
3. Shift elements and insert
4. Repeat for all elements

**Visual Example:**
[5, 2, 4, 6, 1, 3]
[5] | 2, 4, 6, 1, 3 - Insert 2
[2, 5] | 4, 6, 1, 3 - Insert 4
[2, 4, 5] | 6, 1, 3 - Insert 6
[2, 4, 5, 6] | 1, 3 - Insert 1
[1, 2, 4, 5, 6] | 3 - Insert 3
[1, 2, 3, 4, 5, 6] 

**Best for:**
• Small datasets
• Nearly sorted arrays
• Online sorting (stream)
''',
    code: '''#include <stdio.h>

void insertionSort(int arr[], int n) {
    for (int i = 1; i < n; i++) {
        int key = arr[i];  // Element to insert
        int j = i - 1;
        
        // Shift larger elements right
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        
        arr[j + 1] = key;  // Insert at correct position
        
        printf("Pass %d: ", i);
        for (int k = 0; k < n; k++) printf("%d ", arr[k]);
        printf("\\n");
    }
}

// Binary Insertion Sort - fewer comparisons
void binaryInsertionSort(int arr[], int n) {
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        
        // Binary search for insertion point
        int left = 0, right = i - 1;
        while (left <= right) {
            int mid = (left + right) / 2;
            if (arr[mid] > key) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
        
        // Shift elements
        for (int j = i - 1; j >= left; j--) {
            arr[j + 1] = arr[j];
        }
        arr[left] = key;
    }
}

// Insertion sort is best for nearly sorted arrays
void demonstrateNearlySorted() {
    int nearly[] = {1, 2, 3, 5, 4, 6, 7, 9, 8, 10};
    int n = 10;
    int swaps = 0;
    
    printf("Nearly sorted array: ");
    for (int i = 0; i < n; i++) printf("%d ", nearly[i]);
    printf("\\n");
    
    for (int i = 1; i < n; i++) {
        int key = nearly[i];
        int j = i - 1;
        while (j >= 0 && nearly[j] > key) {
            nearly[j + 1] = nearly[j];
            j--;
            swaps++;
        }
        nearly[j + 1] = key;
    }
    
    printf("Only %d shifts needed!\\n", swaps);
}

int main() {
    int arr[] = {5, 2, 4, 6, 1, 3};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    printf("Original: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\n");
    
    insertionSort(arr, n);
    
    printf("\\nSorted: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n\\n");
    
    demonstrateNearlySorted();
    
    return 0;
}''',
    timeComplexity: 'Best: O(n), Average/Worst: O(n²)',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Builds sorted portion incrementally',
      'Excellent for nearly sorted data',
      'Stable sorting algorithm',
      'Online algorithm (works with streams)',
    ],
    iconName: 'playlist_add',
    colorValue: 0xFFE74C3C,
  ),

  // Sorting - Program 4: Merge Sort
  DSProgram(
    id: 'merge_sort',
    title: 'Merge Sort Algorithm',
    topic: 'Sorting',
    description: 'Divide and conquer with guaranteed O(n log n)',
    explanation: '''
Divide array, sort halves, merge them back.

**How it works:**
1. Divide array into two halves
2. Recursively sort each half
3. Merge sorted halves

**Visual Example:**
      [38, 27, 43, 3]
         /        \\
    [38, 27]    [43, 3]
     /   \\       /   \\
   [38] [27]   [43] [3]
     \\   /       \\   /
    [27, 38]    [3, 43]
         \\        /
      [3, 27, 38, 43]

**Key Properties:**
• Always O(n log n)
• Stable sort
• Needs extra space
• Great for linked lists
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Merge two sorted subarrays
void merge(int arr[], int left, int mid, int right) {
    int n1 = mid - left + 1;
    int n2 = right - mid;
    
    // Create temp arrays
    int* L = (int*)malloc(n1 * sizeof(int));
    int* R = (int*)malloc(n2 * sizeof(int));
    
    // Copy data
    for (int i = 0; i < n1; i++) L[i] = arr[left + i];
    for (int j = 0; j < n2; j++) R[j] = arr[mid + 1 + j];
    
    // Merge back
    int i = 0, j = 0, k = left;
    
    while (i < n1 && j < n2) {
        if (L[i] <= R[j]) {
            arr[k++] = L[i++];
        } else {
            arr[k++] = R[j++];
        }
    }
    
    // Copy remaining
    while (i < n1) arr[k++] = L[i++];
    while (j < n2) arr[k++] = R[j++];
    
    free(L);
    free(R);
}

// Recursive Merge Sort
void mergeSort(int arr[], int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        
        // Sort halves
        mergeSort(arr, left, mid);
        mergeSort(arr, mid + 1, right);
        
        // Merge sorted halves
        merge(arr, left, mid, right);
        
        printf("After merge [%d-%d]: ", left, right);
        for (int i = left; i <= right; i++) printf("%d ", arr[i]);
        printf("\\n");
    }
}

// Count inversions using merge sort
long long countInversions(int arr[], int temp[], int left, int right) {
    long long count = 0;
    
    if (left < right) {
        int mid = (left + right) / 2;
        count += countInversions(arr, temp, left, mid);
        count += countInversions(arr, temp, mid + 1, right);
        
        // Count during merge
        int i = left, j = mid + 1, k = left;
        while (i <= mid && j <= right) {
            if (arr[i] <= arr[j]) {
                temp[k++] = arr[i++];
            } else {
                temp[k++] = arr[j++];
                count += (mid - i + 1);  // Count inversions
            }
        }
        while (i <= mid) temp[k++] = arr[i++];
        while (j <= right) temp[k++] = arr[j++];
        
        for (i = left; i <= right; i++) arr[i] = temp[i];
    }
    
    return count;
}

void printArray(int arr[], int n) {
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n");
}

int main() {
    int arr[] = {38, 27, 43, 3, 9, 82, 10};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    printf("Original: ");
    printArray(arr, n);
    printf("\\n");
    
    mergeSort(arr, 0, n - 1);
    
    printf("\\nSorted: ");
    printArray(arr, n);
    
    return 0;
}''',
    timeComplexity: 'O(n log n) always',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Divide and conquer strategy',
      'Guaranteed O(n log n) performance',
      'Stable - maintains equal element order',
      'Requires O(n) extra space',
    ],
    iconName: 'call_split',
    colorValue: 0xFFE74C3C,
  ),

  // Sorting - Program 5: Quick Sort
  DSProgram(
    id: 'quick_sort',
    title: 'Quick Sort Algorithm',
    topic: 'Sorting',
    description: 'Efficient divide and conquer with partitioning',
    explanation: '''
Choose pivot, partition around it, recurse on parts.

**How it works:**
1. Choose a pivot element
2. Partition: smaller elements left, larger right
3. Recursively sort partitions

**Partition Process:**
[10, 80, 30, 90, 40, 50, 70] pivot=70
        ↓ partition ↓
[10, 30, 40, 50, 70, 90, 80]
 < 70    =   > 70

**Pivot Selection:**
• Last element (simple)
• First element
• Median of three
• Random (avoids worst case)

**In practice:** Fastest for most data!
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Partition with last element as pivot
int partition(int arr[], int low, int high) {
    int pivot = arr[high];
    int i = low - 1;
    
    for (int j = low; j < high; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    
    swap(&arr[i + 1], &arr[high]);
    return i + 1;
}

// Randomized partition (avoids worst case)
int randomPartition(int arr[], int low, int high) {
    int random = low + rand() % (high - low + 1);
    swap(&arr[random], &arr[high]);
    return partition(arr, low, high);
}

// Quick Sort
void quickSort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        
        printf("Pivot=%d: ", arr[pi]);
        for (int i = low; i <= high; i++) printf("%d ", arr[i]);
        printf("\\n");
        
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

// Iterative Quick Sort using stack
void quickSortIterative(int arr[], int low, int high) {
    int stack[high - low + 1];
    int top = -1;
    
    stack[++top] = low;
    stack[++top] = high;
    
    while (top >= 0) {
        high = stack[top--];
        low = stack[top--];
        
        int pi = partition(arr, low, high);
        
        if (pi - 1 > low) {
            stack[++top] = low;
            stack[++top] = pi - 1;
        }
        
        if (pi + 1 < high) {
            stack[++top] = pi + 1;
            stack[++top] = high;
        }
    }
}

// 3-way partition for duplicate handling
void quickSort3Way(int arr[], int low, int high) {
    if (low >= high) return;
    
    int lt = low, gt = high;
    int pivot = arr[low];
    int i = low + 1;
    
    while (i <= gt) {
        if (arr[i] < pivot) swap(&arr[lt++], &arr[i++]);
        else if (arr[i] > pivot) swap(&arr[i], &arr[gt--]);
        else i++;
    }
    
    quickSort3Way(arr, low, lt - 1);
    quickSort3Way(arr, gt + 1, high);
}

void printArray(int arr[], int n) {
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n");
}

int main() {
    srand(time(NULL));
    
    int arr[] = {10, 80, 30, 90, 40, 50, 70};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    printf("Original: ");
    printArray(arr, n);
    printf("\\n");
    
    quickSort(arr, 0, n - 1);
    
    printf("\\nSorted: ");
    printArray(arr, n);
    
    // Test with duplicates
    printf("\\n3-way QuickSort with duplicates:\\n");
    int arr2[] = {4, 2, 4, 1, 4, 3, 4, 2};
    printArray(arr2, 8);
    quickSort3Way(arr2, 0, 7);
    printf("Result: ");
    printArray(arr2, 8);
    
    return 0;
}''',
    timeComplexity: 'Best/Avg: O(n log n), Worst: O(n²)',
    spaceComplexity: 'O(log n) stack',
    keyPoints: [
      'Fastest practical sorting algorithm',
      'In-place (minimal extra space)',
      'Not stable',
      'Random pivot avoids worst case',
    ],
    iconName: 'flash_on',
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

  // Trees - Program 2: BST Search and Insert
  DSProgram(
    id: 'bst_operations',
    title: 'BST Search and Insert',
    topic: 'Trees',
    description: 'Binary Search Tree operations for efficient lookup',
    explanation: '''
BST Property: Left < Root < Right for all nodes.

**Search O(log n):**
1. Compare with root
2. If smaller, go left
3. If larger, go right
4. Repeat until found or null

**Insert O(log n):**
1. Search for correct position
2. Insert as leaf node

**Example BST:**
        50
       /  \\
      30   70
     / \\   / \\
    20 40 60 80

Search 60: 50→70→60 ✓ (3 comparisons)
Insert 25: 50→30→20→(left child)
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

struct Node* createNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->left = node->right = NULL;
    return node;
}

// Search in BST - O(log n) average
struct Node* search(struct Node* root, int key) {
    if (root == NULL || root->data == key) {
        return root;
    }
    
    if (key < root->data) {
        return search(root->left, key);
    }
    return search(root->right, key);
}

// Insert in BST - O(log n) average
struct Node* insert(struct Node* root, int data) {
    if (root == NULL) {
        return createNode(data);
    }
    
    if (data < root->data) {
        root->left = insert(root->left, data);
    } else if (data > root->data) {
        root->right = insert(root->right, data);
    }
    // Duplicate values ignored
    
    return root;
}

// Find minimum value node
struct Node* findMin(struct Node* root) {
    while (root && root->left) {
        root = root->left;
    }
    return root;
}

// Find maximum value node
struct Node* findMax(struct Node* root) {
    while (root && root->right) {
        root = root->right;
    }
    return root;
}

// Inorder traversal (gives sorted output)
void inorder(struct Node* root) {
    if (root) {
        inorder(root->left);
        printf("%d ", root->data);
        inorder(root->right);
    }
}

int main() {
    struct Node* root = NULL;
    
    // Build BST
    int values[] = {50, 30, 70, 20, 40, 60, 80};
    int n = sizeof(values) / sizeof(values[0]);
    
    for (int i = 0; i < n; i++) {
        root = insert(root, values[i]);
        printf("Inserted %d\\n", values[i]);
    }
    
    printf("\\nInorder (sorted): ");
    inorder(root);
    
    printf("\\n\\nMin: %d, Max: %d\\n", findMin(root)->data, findMax(root)->data);
    
    // Search
    int key = 40;
    struct Node* result = search(root, key);
    printf("\\nSearch %d: %s\\n", key, result ? "Found" : "Not Found");
    
    return 0;
}''',
    timeComplexity: 'O(log n) average, O(n) worst (skewed)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'BST property: left < root < right',
      'Search and insert are O(log n) average',
      'Inorder traversal gives sorted order',
      'Degrades to O(n) for skewed trees',
    ],
    iconName: 'search',
    colorValue: 0xFF27AE60,
  ),

  // Trees - Program 3: Level Order Traversal (BFS)
  DSProgram(
    id: 'tree_level_order',
    title: 'Level Order Traversal (BFS)',
    topic: 'Trees',
    description: 'Visit tree nodes level by level using queue',
    explanation: '''
Visit all nodes at each level before moving deeper.

**Algorithm:**
1. Add root to queue
2. While queue not empty:
   - Dequeue node, print it
   - Enqueue left child if exists
   - Enqueue right child if exists

**Example:**
        1
       / \\
      2   3
     / \\   \\
    4   5   6

Level Order: 1, 2, 3, 4, 5, 6

**Uses:**
• Print tree level by level
• Find shortest path
• Zigzag traversal
• Right view of tree
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

// Queue for BFS
struct Queue {
    struct Node* items[100];
    int front, rear;
};

void initQueue(struct Queue* q) { q->front = q->rear = -1; }
int isQueueEmpty(struct Queue* q) { return q->front == -1; }

void enqueue(struct Queue* q, struct Node* node) {
    if (q->front == -1) q->front = 0;
    q->items[++q->rear] = node;
}

struct Node* dequeue(struct Queue* q) {
    struct Node* item = q->items[q->front];
    if (q->front == q->rear) q->front = q->rear = -1;
    else q->front++;
    return item;
}

struct Node* createNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->left = node->right = NULL;
    return node;
}

// Level Order Traversal
void levelOrder(struct Node* root) {
    if (root == NULL) return;
    
    struct Queue q;
    initQueue(&q);
    enqueue(&q, root);
    
    while (!isQueueEmpty(&q)) {
        struct Node* current = dequeue(&q);
        printf("%d ", current->data);
        
        if (current->left) enqueue(&q, current->left);
        if (current->right) enqueue(&q, current->right);
    }
}

// Level Order with level markers
void levelOrderByLevel(struct Node* root) {
    if (root == NULL) return;
    
    struct Queue q;
    initQueue(&q);
    enqueue(&q, root);
    int level = 0;
    
    while (!isQueueEmpty(&q)) {
        int levelSize = q.rear - q.front + 1;
        printf("Level %d: ", level);
        
        for (int i = 0; i < levelSize; i++) {
            struct Node* current = dequeue(&q);
            printf("%d ", current->data);
            
            if (current->left) enqueue(&q, current->left);
            if (current->right) enqueue(&q, current->right);
        }
        printf("\\n");
        level++;
    }
}

// Right Side View
void rightView(struct Node* root) {
    if (root == NULL) return;
    
    struct Queue q;
    initQueue(&q);
    enqueue(&q, root);
    
    printf("Right View: ");
    while (!isQueueEmpty(&q)) {
        int levelSize = q.rear - q.front + 1;
        
        for (int i = 0; i < levelSize; i++) {
            struct Node* current = dequeue(&q);
            if (i == levelSize - 1) printf("%d ", current->data);
            
            if (current->left) enqueue(&q, current->left);
            if (current->right) enqueue(&q, current->right);
        }
    }
    printf("\\n");
}

int main() {
    struct Node* root = createNode(1);
    root->left = createNode(2);
    root->right = createNode(3);
    root->left->left = createNode(4);
    root->left->right = createNode(5);
    root->right->right = createNode(6);
    
    printf("Level Order: ");
    levelOrder(root);
    printf("\\n\\n");
    
    levelOrderByLevel(root);
    printf("\\n");
    
    rightView(root);
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(w) where w is max width',
    keyPoints: [
      'Uses queue for BFS traversal',
      'Visits nodes level by level',
      'Useful for level-wise operations',
      'Can find tree width and depth',
    ],
    iconName: 'layers',
    colorValue: 0xFF27AE60,
  ),

  // Trees - Program 4: BST Delete Operation
  DSProgram(
    id: 'bst_delete',
    title: 'BST Delete Operation',
    topic: 'Trees',
    description: 'Remove nodes from Binary Search Tree',
    explanation: '''
Deleting from BST has 3 cases:

**Case 1: Leaf Node**
Simply remove it.

**Case 2: One Child**
Replace node with its child.

**Case 3: Two Children**
Replace with inorder successor (or predecessor).
Then delete the successor.

**Example (delete 30):**
        50               50
       /  \\    →        /  \\
      30   70          40   70
     / \\              /
    20 40            20

Find successor (40), copy value, delete successor.
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

struct Node* createNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->left = node->right = NULL;
    return node;
}

struct Node* insert(struct Node* root, int data) {
    if (root == NULL) return createNode(data);
    if (data < root->data) root->left = insert(root->left, data);
    else if (data > root->data) root->right = insert(root->right, data);
    return root;
}

// Find minimum (inorder successor for delete)
struct Node* findMin(struct Node* root) {
    while (root && root->left) root = root->left;
    return root;
}

// Delete a node from BST
struct Node* deleteNode(struct Node* root, int key) {
    if (root == NULL) return root;
    
    // Find the node
    if (key < root->data) {
        root->left = deleteNode(root->left, key);
    } else if (key > root->data) {
        root->right = deleteNode(root->right, key);
    } else {
        // Found node to delete
        
        // Case 1 & 2: No child or one child
        if (root->left == NULL) {
            struct Node* temp = root->right;
            free(root);
            return temp;
        } else if (root->right == NULL) {
            struct Node* temp = root->left;
            free(root);
            return temp;
        }
        
        // Case 3: Two children
        // Get inorder successor (smallest in right subtree)
        struct Node* successor = findMin(root->right);
        
        // Copy successor's value
        root->data = successor->data;
        
        // Delete the successor
        root->right = deleteNode(root->right, successor->data);
    }
    
    return root;
}

void inorder(struct Node* root) {
    if (root) {
        inorder(root->left);
        printf("%d ", root->data);
        inorder(root->right);
    }
}

int main() {
    struct Node* root = NULL;
    int values[] = {50, 30, 70, 20, 40, 60, 80};
    
    for (int i = 0; i < 7; i++) {
        root = insert(root, values[i]);
    }
    
    printf("Original BST (inorder): ");
    inorder(root);
    
    // Delete leaf
    printf("\\n\\nDelete 20 (leaf): ");
    root = deleteNode(root, 20);
    inorder(root);
    
    // Delete node with one child
    printf("\\n\\nDelete 30 (one child now): ");
    root = deleteNode(root, 30);
    inorder(root);
    
    // Delete node with two children
    printf("\\n\\nDelete 50 (root, two children): ");
    root = deleteNode(root, 50);
    inorder(root);
    
    printf("\\n");
    return 0;
}''',
    timeComplexity: 'O(log n) average, O(n) worst',
    spaceComplexity: 'O(h) recursion stack',
    keyPoints: [
      'Three cases: leaf, one child, two children',
      'Two children: use inorder successor',
      'Maintains BST property after deletion',
      'Handle root deletion carefully',
    ],
    iconName: 'remove_circle',
    colorValue: 0xFF27AE60,
  ),

  // Trees - Program 5: Validate BST
  DSProgram(
    id: 'validate_bst',
    title: 'Check if Valid BST',
    topic: 'Trees',
    description: 'Verify if a binary tree satisfies BST property',
    explanation: '''
A valid BST has ALL left descendants < node < ALL right descendants.

**Wrong approach:**
Only check node.left < node < node.right (doesn't catch all violations)

**Correct approach:**
Track valid range [min, max] for each node.

**Example (Invalid):**
        10
       /  \\
      5   15     ← Looks OK at each node
         / \\
        6  20    ← But 6 < 10! Invalid!

**Algorithm:**
• Root: range (-∞, +∞)
• Left child: range (min, parent)
• Right child: range (parent, max)
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

struct Node* createNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->left = node->right = NULL;
    return node;
}

// Method 1: Using min/max range
bool isValidBSTHelper(struct Node* root, long min, long max) {
    if (root == NULL) return true;
    
    if (root->data <= min || root->data >= max) {
        return false;
    }
    
    return isValidBSTHelper(root->left, min, root->data) &&
           isValidBSTHelper(root->right, root->data, max);
}

bool isValidBST(struct Node* root) {
    return isValidBSTHelper(root, LONG_MIN, LONG_MAX);
}

// Method 2: Inorder should be strictly increasing
int prev = INT_MIN;
bool inorderValid = true;

void checkInorder(struct Node* root) {
    if (root == NULL || !inorderValid) return;
    
    checkInorder(root->left);
    
    if (root->data <= prev) {
        inorderValid = false;
        return;
    }
    prev = root->data;
    
    checkInorder(root->right);
}

bool isValidBSTInorder(struct Node* root) {
    prev = INT_MIN;
    inorderValid = true;
    checkInorder(root);
    return inorderValid;
}

// Find floor (largest element <= key)
struct Node* floor(struct Node* root, int key) {
    struct Node* result = NULL;
    
    while (root) {
        if (root->data == key) return root;
        if (root->data < key) {
            result = root;
            root = root->right;
        } else {
            root = root->left;
        }
    }
    
    return result;
}

// Find ceil (smallest element >= key)
struct Node* ceil(struct Node* root, int key) {
    struct Node* result = NULL;
    
    while (root) {
        if (root->data == key) return root;
        if (root->data > key) {
            result = root;
            root = root->left;
        } else {
            root = root->right;
        }
    }
    
    return result;
}

int main() {
    // Valid BST
    struct Node* valid = createNode(10);
    valid->left = createNode(5);
    valid->right = createNode(15);
    valid->right->left = createNode(12);
    valid->right->right = createNode(20);
    
    printf("Valid BST: %s\\n", isValidBST(valid) ? "Yes" : "No");
    
    // Invalid BST (6 is in wrong position)
    struct Node* invalid = createNode(10);
    invalid->left = createNode(5);
    invalid->right = createNode(15);
    invalid->right->left = createNode(6);  // Violation: 6 < 10
    invalid->right->right = createNode(20);
    
    printf("Invalid BST: %s\\n", isValidBST(invalid) ? "Yes" : "No");
    
    // Floor and Ceil
    struct Node* floorNode = floor(valid, 13);
    struct Node* ceilNode = ceil(valid, 13);
    
    printf("\\nFloor of 13: %d\\n", floorNode ? floorNode->data : -1);
    printf("Ceil of 13: %d\\n", ceilNode ? ceilNode->data : -1);
    
    return 0;
}''',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h) recursion stack',
    keyPoints: [
      'Track valid range for each node',
      'Check ALL descendants, not just children',
      'Inorder traversal should be sorted',
      'Common interview question',
    ],
    iconName: 'verified',
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

  // Recursion - Program 2: Tower of Hanoi
  DSProgram(
    id: 'tower_of_hanoi',
    title: 'Tower of Hanoi',
    topic: 'Recursion',
    description: 'Classic recursive puzzle with exponential moves',
    explanation: '''
Move n disks from source to destination using auxiliary peg.

**Rules:**
1. Only one disk moved at a time
2. Only top disk can be moved
3. Larger disk cannot be on smaller disk

**Recursive Solution:**
1. Move n-1 disks: Source → Auxiliary
2. Move largest disk: Source → Destination
3. Move n-1 disks: Auxiliary → Destination

**Example (3 disks):**
    |         |         |
   [1]        |         |
  [=2=]       |         |
 [==3==]      |         |
  Source    Aux       Dest

Moves needed: 2^n - 1 = 7 moves
''',
    code: '''#include <stdio.h>

int moveCount = 0;

void towerOfHanoi(int n, char source, char dest, char aux) {
    if (n == 1) {
        moveCount++;
        printf("Move %d: Disk 1 from %c to %c\\n", moveCount, source, dest);
        return;
    }
    
    // Move n-1 disks from source to auxiliary
    towerOfHanoi(n - 1, source, aux, dest);
    
    // Move largest disk from source to destination
    moveCount++;
    printf("Move %d: Disk %d from %c to %c\\n", moveCount, n, source, dest);
    
    // Move n-1 disks from auxiliary to destination
    towerOfHanoi(n - 1, aux, dest, source);
}

// Count moves without printing
int countMoves(int n) {
    if (n == 1) return 1;
    return 2 * countMoves(n - 1) + 1;
}

// Iterative solution (binary counting method)
void towerOfHanoiIterative(int n, char source, char dest, char aux) {
    int totalMoves = (1 << n) - 1;  // 2^n - 1
    char pegs[3] = {source, dest, aux};
    
    // For odd number of disks, swap dest and aux
    if (n % 2 == 1) {
        char temp = pegs[1];
        pegs[1] = pegs[2];
        pegs[2] = temp;
    }
    
    for (int i = 1; i <= totalMoves; i++) {
        int from = (i & (i - 1)) % 3;
        int to = ((i | (i - 1)) + 1) % 3;
        printf("Move disk from %c to %c\\n", pegs[from], pegs[to]);
    }
}

int main() {
    int n = 3;
    
    printf("Tower of Hanoi with %d disks:\\n\\n", n);
    towerOfHanoi(n, 'A', 'C', 'B');
    
    printf("\\nTotal moves: %d\\n", moveCount);
    printf("Formula: 2^%d - 1 = %d\\n", n, (1 << n) - 1);
    
    return 0;
}''',
    timeComplexity: 'O(2^n)',
    spaceComplexity: 'O(n) stack depth',
    keyPoints: [
      'Classic recursion example',
      'Minimum moves: 2^n - 1',
      'Exponential time complexity',
      'Can be solved iteratively using binary',
    ],
    iconName: 'stacked_bar_chart',
    colorValue: 0xFFF39C12,
  ),

  // Recursion - Program 3: Generate Permutations
  DSProgram(
    id: 'permutations',
    title: 'Generate Permutations',
    topic: 'Recursion',
    description: 'Generate all arrangements of elements',
    explanation: '''
Permutation = arrangement of all elements in different orders.

**For [1, 2, 3]:**
[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]
Total: 3! = 6 permutations

**Algorithm (Backtracking):**
1. For each position, try each unused element
2. Mark element as used
3. Recurse for remaining positions
4. Unmark (backtrack) and try next

**Swap Method:**
Fix element at each position by swapping:
[1,2,3] → swap(0,0) → [1,2,3]
         swap(1,1) → [1,2,3] ✓
         swap(1,2) → [1,3,2] ✓
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <stdbool.h>

int count = 0;

void swap(char* a, char* b) {
    char temp = *a;
    *a = *b;
    *b = temp;
}

// Permutation using swap
void permute(char* str, int left, int right) {
    if (left == right) {
        count++;
        printf("%d: %s\\n", count, str);
        return;
    }
    
    for (int i = left; i <= right; i++) {
        swap(&str[left], &str[i]);
        permute(str, left + 1, right);
        swap(&str[left], &str[i]);  // Backtrack
    }
}

// Permutation with duplicates handling
void permuteUnique(char* str, int left, int right) {
    if (left == right) {
        count++;
        printf("%d: %s\\n", count, str);
        return;
    }
    
    bool used[256] = {false};
    
    for (int i = left; i <= right; i++) {
        if (used[(int)str[i]]) continue;  // Skip duplicates
        used[(int)str[i]] = true;
        
        swap(&str[left], &str[i]);
        permuteUnique(str, left + 1, right);
        swap(&str[left], &str[i]);
    }
}

// Next permutation (lexicographically)
bool nextPermutation(char* str, int n) {
    // Find rightmost element smaller than its next
    int i = n - 2;
    while (i >= 0 && str[i] >= str[i + 1]) i--;
    
    if (i < 0) return false;  // Last permutation
    
    // Find rightmost element greater than str[i]
    int j = n - 1;
    while (str[j] <= str[i]) j--;
    
    swap(&str[i], &str[j]);
    
    // Reverse from i+1 to end
    int left = i + 1, right = n - 1;
    while (left < right) {
        swap(&str[left++], &str[right--]);
    }
    
    return true;
}

int main() {
    char str[] = "ABC";
    int n = strlen(str);
    
    printf("Permutations of %s:\\n", str);
    permute(str, 0, n - 1);
    
    printf("\\nTotal: %d (expected %d! = %d)\\n", count, n, 
           n == 1 ? 1 : n == 2 ? 2 : n == 3 ? 6 : n * (n-1));
    
    // With duplicates
    printf("\\nPermutations of AAB (unique):\\n");
    char str2[] = "AAB";
    count = 0;
    permuteUnique(str2, 0, 2);
    
    return 0;
}''',
    timeComplexity: 'O(n! * n)',
    spaceComplexity: 'O(n) stack',
    keyPoints: [
      'Total permutations = n!',
      'Swap method is efficient',
      'Handle duplicates with hash set',
      'Used in combinatorial problems',
    ],
    iconName: 'shuffle',
    colorValue: 0xFFF39C12,
  ),

  // Recursion - Program 4: N-Queens Problem
  DSProgram(
    id: 'n_queens',
    title: 'N-Queens Problem',
    topic: 'Recursion',
    description: 'Place N queens on NxN board without attacks',
    explanation: '''
Place N queens so no two attack each other.

**Queen attacks:**
• Same row ↔
• Same column ↕
• Same diagonal ↗↙↘↖

**Backtracking Approach:**
1. Place queen in row 0, column 0
2. Try to place queen in row 1 (check safety)
3. If safe, continue; else try next column
4. If no column works, backtrack to previous row

**4-Queens Solution:**
  0 1 2 3
0 . Q . .
1 . . . Q
2 Q . . .
3 . . Q .

**Total solutions:**
4×4: 2, 8×8: 92
''',
    code: '''#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

int solutionCount = 0;

void printBoard(int* board, int n) {
    printf("Solution %d:\\n", solutionCount);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf(j == board[i] ? " Q" : " .");
        }
        printf("\\n");
    }
    printf("\\n");
}

// Check if queen at (row, col) is safe
bool isSafe(int* board, int row, int col) {
    for (int i = 0; i < row; i++) {
        // Same column
        if (board[i] == col) return false;
        
        // Same diagonal
        if (abs(board[i] - col) == abs(i - row)) return false;
    }
    return true;
}

void solveNQueens(int* board, int row, int n, bool printAll) {
    if (row == n) {
        solutionCount++;
        if (printAll) printBoard(board, n);
        return;
    }
    
    for (int col = 0; col < n; col++) {
        if (isSafe(board, row, col)) {
            board[row] = col;
            solveNQueens(board, row + 1, n, printAll);
            // Backtrack (implicit, next iteration overwrites)
        }
    }
}

// Optimized with bit manipulation
int countQueens(int n, int col, int diag1, int diag2) {
    if (col == (1 << n) - 1) return 1;  // All columns filled
    
    int available = ((1 << n) - 1) & ~(col | diag1 | diag2);
    int count = 0;
    
    while (available) {
        int pos = available & (-available);  // Rightmost bit
        available -= pos;
        count += countQueens(n, 
                            col | pos, 
                            (diag1 | pos) << 1, 
                            (diag2 | pos) >> 1);
    }
    
    return count;
}

int main() {
    int n = 4;
    int* board = (int*)malloc(n * sizeof(int));
    
    printf("N-Queens for N=%d\\n\\n", n);
    solveNQueens(board, 0, n, true);
    printf("Total solutions for N=%d: %d\\n\\n", n, solutionCount);
    
    // Count for 8-queens
    printf("Solutions for 8-Queens: %d\\n", countQueens(8, 0, 0, 0));
    
    free(board);
    return 0;
}''',
    timeComplexity: 'O(n!)',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Classic backtracking problem',
      'Check row, column, and diagonals',
      'Bit manipulation for optimization',
      '92 solutions for 8-Queens',
    ],
    iconName: 'grid_on',
    colorValue: 0xFFF39C12,
  ),

  // Recursion - Program 5: Subset Sum
  DSProgram(
    id: 'subset_sum',
    title: 'Subset Sum Problem',
    topic: 'Recursion',
    description: 'Find subsets that sum to target value',
    explanation: '''
Find if subset exists with given sum.

**Example:**
arr = [3, 1, 5, 9, 12], target = 9

Subsets with sum 9:
• [9] ✓
• [3, 1, 5] ✓

**Recursive Approach:**
For each element, two choices:
1. Include it (reduce target)
2. Exclude it (keep target)

**Decision Tree (simplified):**
                    sum=9
                   /     \\
             [3]sum=6  []sum=9
             /    \\      ...
       [3,1]s=5 [3]s=6
          ...

**Used in:** Knapsack problem, partition problem
''',
    code: '''#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

// Check if subset with given sum exists
bool subsetSum(int arr[], int n, int sum) {
    if (sum == 0) return true;
    if (n == 0) return false;
    
    // If current element > sum, exclude it
    if (arr[n - 1] > sum) {
        return subsetSum(arr, n - 1, sum);
    }
    
    // Include or exclude current element
    return subsetSum(arr, n - 1, sum - arr[n - 1]) ||
           subsetSum(arr, n - 1, sum);
}

// Print all subsets with given sum
void printSubsets(int arr[], int n, int sum, int* subset, int subsetSize) {
    if (sum == 0) {
        printf("{ ");
        for (int i = 0; i < subsetSize; i++) {
            printf("%d ", subset[i]);
        }
        printf("}\\n");
        return;
    }
    
    if (n == 0) return;
    
    // Exclude current element
    printSubsets(arr, n - 1, sum, subset, subsetSize);
    
    // Include current element
    if (arr[n - 1] <= sum) {
        subset[subsetSize] = arr[n - 1];
        printSubsets(arr, n - 1, sum - arr[n - 1], subset, subsetSize + 1);
    }
}

// Count subsets with given sum
int countSubsets(int arr[], int n, int sum) {
    if (sum == 0) return 1;
    if (n == 0) return 0;
    
    if (arr[n - 1] > sum) {
        return countSubsets(arr, n - 1, sum);
    }
    
    return countSubsets(arr, n - 1, sum - arr[n - 1]) +
           countSubsets(arr, n - 1, sum);
}

// DP solution - O(n * sum)
bool subsetSumDP(int arr[], int n, int sum) {
    bool** dp = (bool**)malloc((n + 1) * sizeof(bool*));
    for (int i = 0; i <= n; i++) {
        dp[i] = (bool*)calloc(sum + 1, sizeof(bool));
    }
    
    // Base case: sum 0 is always possible
    for (int i = 0; i <= n; i++) dp[i][0] = true;
    
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= sum; j++) {
            dp[i][j] = dp[i - 1][j];  // Exclude
            if (arr[i - 1] <= j) {
                dp[i][j] = dp[i][j] || dp[i - 1][j - arr[i - 1]];
            }
        }
    }
    
    bool result = dp[n][sum];
    
    for (int i = 0; i <= n; i++) free(dp[i]);
    free(dp);
    
    return result;
}

int main() {
    int arr[] = {3, 1, 5, 9, 12};
    int n = sizeof(arr) / sizeof(arr[0]);
    int sum = 9;
    
    printf("Array: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\nTarget sum: %d\\n\\n", sum);
    
    printf("Subset exists: %s\\n\\n", subsetSum(arr, n, sum) ? "Yes" : "No");
    
    printf("All subsets with sum %d:\\n", sum);
    int* subset = (int*)malloc(n * sizeof(int));
    printSubsets(arr, n, sum, subset, 0);
    
    printf("\\nCount of subsets: %d\\n", countSubsets(arr, n, sum));
    
    free(subset);
    return 0;
}''',
    timeComplexity: 'Recursive: O(2^n), DP: O(n*sum)',
    spaceComplexity: 'O(n) recursive, O(n*sum) DP',
    keyPoints: [
      'Include/exclude pattern',
      'Base case: sum=0 is true',
      'DP improves to O(n*sum)',
      'Foundation for knapsack problems',
    ],
    iconName: 'add_box',
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

  // Strings - Program 2: String Comparison & Anagram
  DSProgram(
    id: 'string_compare',
    title: 'String Comparison & Anagram',
    topic: 'Strings',
    description: 'Compare strings and check for anagrams',
    explanation: '''
String comparison is fundamental for sorting and searching.

**strcmp(s1, s2):**
• Returns 0 if equal
• Returns negative if s1 < s2
• Returns positive if s1 > s2

**Anagram:**
Two strings are anagrams if they have same characters in different order.
Example: "listen" and "silent"

**Methods to check anagram:**
1. Sort both and compare
2. Count character frequencies
3. Use hash map
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

// Custom strcmp implementation
int myStrcmp(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char*)s1 - *(unsigned char*)s2;
}

// Case-insensitive compare
int strcmpIgnoreCase(const char* s1, const char* s2) {
    while (*s1 && tolower(*s1) == tolower(*s2)) {
        s1++;
        s2++;
    }
    return tolower(*s1) - tolower(*s2);
}

// Check if two strings are anagrams
bool areAnagrams(const char* s1, const char* s2) {
    int count[256] = {0};
    
    // Count characters in s1
    while (*s1) {
        if (isalpha(*s1)) {
            count[tolower(*s1)]++;
        }
        s1++;
    }
    
    // Subtract counts for s2
    while (*s2) {
        if (isalpha(*s2)) {
            count[tolower(*s2)]--;
        }
        s2++;
    }
    
    // Check if all counts are zero
    for (int i = 0; i < 256; i++) {
        if (count[i] != 0) return false;
    }
    return true;
}

// Check if s2 is rotation of s1
bool isRotation(const char* s1, const char* s2) {
    int len1 = strlen(s1);
    int len2 = strlen(s2);
    
    if (len1 != len2 || len1 == 0) return false;
    
    // Concatenate s1 with itself
    char temp[2 * len1 + 1];
    strcpy(temp, s1);
    strcat(temp, s1);
    
    return strstr(temp, s2) != NULL;
}

int main() {
    printf("=== STRING COMPARISON ===\\n");
    printf("strcmp('apple', 'banana') = %d\\n", myStrcmp("apple", "banana"));
    printf("strcmp('hello', 'hello') = %d\\n", myStrcmp("hello", "hello"));
    printf("strcmpIgnoreCase('Hello', 'HELLO') = %d\\n\\n", 
           strcmpIgnoreCase("Hello", "HELLO"));
    
    printf("=== ANAGRAM CHECK ===\\n");
    printf("'listen' and 'silent': %s\\n", 
           areAnagrams("listen", "silent") ? "Anagram" : "Not Anagram");
    printf("'hello' and 'world': %s\\n\\n", 
           areAnagrams("hello", "world") ? "Anagram" : "Not Anagram");
    
    printf("=== ROTATION CHECK ===\\n");
    printf("'waterbottle' rotated to 'erbottlewat': %s\\n", 
           isRotation("waterbottle", "erbottlewat") ? "Yes" : "No");
    
    return 0;
}''',
    timeComplexity: 'Compare: O(n), Anagram: O(n)',
    spaceComplexity: 'O(1) for compare, O(1) for anagram (fixed 256)',
    keyPoints: [
      'strcmp returns 0 for equal strings',
      'Anagram check uses character counting',
      'Rotation check uses concatenation trick',
      'Case-insensitive compare uses tolower',
    ],
    iconName: 'compare',
    colorValue: 0xFF1ABC9C,
  ),

  // Strings - Program 3: Pattern Matching (KMP)
  DSProgram(
    id: 'pattern_matching',
    title: 'Pattern Matching (KMP)',
    topic: 'Strings',
    description: 'Efficient substring search algorithm',
    explanation: '''
Find pattern in text efficiently.

**Naive: O(n*m)** - Check every position
**KMP: O(n+m)** - Skip unnecessary comparisons

**KMP Key Idea:**
When mismatch occurs, use already matched info.

**LPS Array (Longest Prefix Suffix):**
Pattern: "AABAACAABAA"
LPS:     [0,1,0,1,2,0,1,2,3,4,5]

If mismatch at i, jump to LPS[i-1] instead of 0.

**Example:**
Text: "AAAAABAAABA"
Pattern: "AAAB"
Naive: Many comparisons
KMP: Uses LPS to skip
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Compute LPS (Longest Prefix Suffix) array
void computeLPS(const char* pattern, int m, int* lps) {
    int len = 0;
    lps[0] = 0;
    int i = 1;
    
    while (i < m) {
        if (pattern[i] == pattern[len]) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len != 0) {
                len = lps[len - 1];
            } else {
                lps[i] = 0;
                i++;
            }
        }
    }
}

// KMP Pattern Search
void KMPSearch(const char* text, const char* pattern) {
    int n = strlen(text);
    int m = strlen(pattern);
    
    int* lps = (int*)malloc(m * sizeof(int));
    computeLPS(pattern, m, lps);
    
    printf("Searching '%s' in '%s'\\n", pattern, text);
    printf("LPS: ");
    for (int i = 0; i < m; i++) printf("%d ", lps[i]);
    printf("\\n\\n");
    
    int i = 0;  // text index
    int j = 0;  // pattern index
    int found = 0;
    
    while (i < n) {
        if (pattern[j] == text[i]) {
            i++;
            j++;
        }
        
        if (j == m) {
            printf("Pattern found at index %d\\n", i - j);
            found++;
            j = lps[j - 1];
        } else if (i < n && pattern[j] != text[i]) {
            if (j != 0) {
                j = lps[j - 1];
            } else {
                i++;
            }
        }
    }
    
    if (!found) printf("Pattern not found\\n");
    printf("Total occurrences: %d\\n", found);
    
    free(lps);
}

// Naive search for comparison
int naiveSearch(const char* text, const char* pattern) {
    int n = strlen(text);
    int m = strlen(pattern);
    int count = 0;
    
    for (int i = 0; i <= n - m; i++) {
        int j;
        for (j = 0; j < m; j++) {
            if (text[i + j] != pattern[j]) break;
        }
        if (j == m) count++;
    }
    
    return count;
}

int main() {
    KMPSearch("AABAACAADAABAAABAA", "AABA");
    
    printf("\\n--- Naive comparison ---\\n");
    printf("Naive found: %d occurrences\\n", 
           naiveSearch("AABAACAADAABAAABAA", "AABA"));
    
    return 0;
}''',
    timeComplexity: 'O(n + m)',
    spaceComplexity: 'O(m) for LPS array',
    keyPoints: [
      'LPS array stores prefix-suffix matches',
      'Avoids re-comparing matched characters',
      'Preprocessing takes O(m) time',
      'Used in text editors and search engines',
    ],
    iconName: 'find_in_page',
    colorValue: 0xFF1ABC9C,
  ),

  // Strings - Program 4: Longest Common Subsequence
  DSProgram(
    id: 'string_lcs',
    title: 'Longest Common Subsequence',
    topic: 'Strings',
    description: 'Find longest sequence present in both strings',
    explanation: '''
LCS is longest sequence appearing in both strings (not necessarily contiguous).

**Example:**
s1 = "ABCDGH"
s2 = "AEDFHR"
LCS = "ADH" (length 3)

**Recursive approach:**
If last chars match: 1 + LCS(remaining)
If not: max(exclude from s1, exclude from s2)

**DP Table:**
    "" A E D F H R
""   0 0 0 0 0 0 0
A    0 1 1 1 1 1 1
B    0 1 1 1 1 1 1
C    0 1 1 1 1 1 1
D    0 1 1 2 2 2 2
G    0 1 1 2 2 2 2
H    0 1 1 2 2 3 3
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int max(int a, int b) { return a > b ? a : b; }

// Recursive LCS (exponential)
int lcsRecursive(const char* s1, const char* s2, int m, int n) {
    if (m == 0 || n == 0) return 0;
    
    if (s1[m - 1] == s2[n - 1]) {
        return 1 + lcsRecursive(s1, s2, m - 1, n - 1);
    }
    
    return max(lcsRecursive(s1, s2, m, n - 1),
               lcsRecursive(s1, s2, m - 1, n));
}

// DP LCS - O(mn)
int lcsDP(const char* s1, const char* s2, char* result) {
    int m = strlen(s1);
    int n = strlen(s2);
    
    int** dp = (int**)malloc((m + 1) * sizeof(int*));
    for (int i = 0; i <= m; i++) {
        dp[i] = (int*)calloc(n + 1, sizeof(int));
    }
    
    // Fill DP table
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (s1[i - 1] == s2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
            } else {
                dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
            }
        }
    }
    
    int length = dp[m][n];
    
    // Backtrack to find LCS string
    if (result != NULL) {
        result[length] = '\\0';
        int i = m, j = n, k = length - 1;
        
        while (i > 0 && j > 0) {
            if (s1[i - 1] == s2[j - 1]) {
                result[k--] = s1[i - 1];
                i--;
                j--;
            } else if (dp[i - 1][j] > dp[i][j - 1]) {
                i--;
            } else {
                j--;
            }
        }
    }
    
    for (int i = 0; i <= m; i++) free(dp[i]);
    free(dp);
    
    return length;
}

// Longest Common Substring (contiguous)
int longestCommonSubstring(const char* s1, const char* s2, int* endIdx) {
    int m = strlen(s1);
    int n = strlen(s2);
    int maxLen = 0;
    *endIdx = 0;
    
    int** dp = (int**)malloc((m + 1) * sizeof(int*));
    for (int i = 0; i <= m; i++) {
        dp[i] = (int*)calloc(n + 1, sizeof(int));
    }
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (s1[i - 1] == s2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
                if (dp[i][j] > maxLen) {
                    maxLen = dp[i][j];
                    *endIdx = i - 1;
                }
            }
        }
    }
    
    for (int i = 0; i <= m; i++) free(dp[i]);
    free(dp);
    
    return maxLen;
}

int main() {
    const char* s1 = "ABCDGH";
    const char* s2 = "AEDFHR";
    
    char lcs[100];
    int len = lcsDP(s1, s2, lcs);
    
    printf("String 1: %s\\n", s1);
    printf("String 2: %s\\n", s2);
    printf("LCS: '%s' (length %d)\\n\\n", lcs, len);
    
    // Substring example
    const char* a = "GeeksforGeeks";
    const char* b = "GeeksQuiz";
    int endIdx;
    int subLen = longestCommonSubstring(a, b, &endIdx);
    
    printf("Longest Common Substring in\\n'%s' and '%s'\\n", a, b);
    printf("Length: %d, Ending at index: %d\\n", subLen, endIdx);
    
    return 0;
}''',
    timeComplexity: 'O(m×n)',
    spaceComplexity: 'O(m×n)',
    keyPoints: [
      'Subsequence vs Substring (contiguous)',
      'Classic dynamic programming problem',
      'Used in diff tools and DNA analysis',
      'Can optimize space to O(min(m,n))',
    ],
    iconName: 'compare_arrows',
    colorValue: 0xFF1ABC9C,
  ),

  // Strings - Program 5: String Tokenizer
  DSProgram(
    id: 'string_tokenizer',
    title: 'String Tokenizer',
    topic: 'Strings',
    description: 'Split strings by delimiters',
    explanation: '''
Tokenization = splitting string into parts.

**strtok(str, delim):**
• First call: pass string
• Subsequent calls: pass NULL
• Modifies original string!

**Example:**
"Hello,World;How:Are You"
Delimiters: ",;: "
Tokens: "Hello", "World", "How", "Are", "You"

**Custom tokenizer advantages:**
• Non-destructive
• Reentrant (thread-safe)
• More control over behavior
''',
    code: '''#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

// Check if character is a delimiter
bool isDelimiter(char c, const char* delims) {
    while (*delims) {
        if (c == *delims) return true;
        delims++;
    }
    return false;
}

// Count tokens in string
int countTokens(const char* str, const char* delims) {
    int count = 0;
    bool inToken = false;
    
    while (*str) {
        if (isDelimiter(*str, delims)) {
            inToken = false;
        } else if (!inToken) {
            inToken = true;
            count++;
        }
        str++;
    }
    
    return count;
}

// Custom strtok (non-destructive version)
char** tokenize(const char* str, const char* delims, int* numTokens) {
    *numTokens = countTokens(str, delims);
    char** tokens = (char**)malloc(*numTokens * sizeof(char*));
    
    int tokenIdx = 0;
    const char* start = NULL;
    const char* ptr = str;
    
    while (*ptr) {
        if (!isDelimiter(*ptr, delims)) {
            if (start == NULL) start = ptr;
        } else if (start != NULL) {
            int len = ptr - start;
            tokens[tokenIdx] = (char*)malloc(len + 1);
            strncpy(tokens[tokenIdx], start, len);
            tokens[tokenIdx][len] = '\\0';
            tokenIdx++;
            start = NULL;
        }
        ptr++;
    }
    
    // Handle last token
    if (start != NULL) {
        int len = ptr - start;
        tokens[tokenIdx] = (char*)malloc(len + 1);
        strncpy(tokens[tokenIdx], start, len);
        tokens[tokenIdx][len] = '\\0';
    }
    
    return tokens;
}

// Split by specific delimiter (like split in other languages)
char** split(const char* str, char delim, int* count) {
    char delims[2] = {delim, '\\0'};
    return tokenize(str, delims, count);
}

// Join tokens with delimiter
char* join(char** tokens, int count, const char* delim) {
    int totalLen = 0;
    int delimLen = strlen(delim);
    
    for (int i = 0; i < count; i++) {
        totalLen += strlen(tokens[i]);
        if (i < count - 1) totalLen += delimLen;
    }
    
    char* result = (char*)malloc(totalLen + 1);
    result[0] = '\\0';
    
    for (int i = 0; i < count; i++) {
        strcat(result, tokens[i]);
        if (i < count - 1) strcat(result, delim);
    }
    
    return result;
}

int main() {
    const char* str = "Hello,World;How:Are You";
    const char* delims = ",;: ";
    
    printf("Original: '%s'\\n", str);
    printf("Delimiters: '%s'\\n\\n", delims);
    
    int numTokens;
    char** tokens = tokenize(str, delims, &numTokens);
    
    printf("Tokens (%d):\\n", numTokens);
    for (int i = 0; i < numTokens; i++) {
        printf("  [%d]: '%s'\\n", i, tokens[i]);
    }
    
    // Join with different delimiter
    char* joined = join(tokens, numTokens, " - ");
    printf("\\nJoined: '%s'\\n", joined);
    
    // Cleanup
    for (int i = 0; i < numTokens; i++) free(tokens[i]);
    free(tokens);
    free(joined);
    
    // Using strtok (destructive)
    printf("\\n--- Using strtok ---\\n");
    char copy[] = "one,two,three";
    char* token = strtok(copy, ",");
    while (token != NULL) {
        printf("Token: '%s'\\n", token);
        token = strtok(NULL, ",");
    }
    
    return 0;
}''',
    timeComplexity: 'O(n * d) where d is delimiter count',
    spaceComplexity: 'O(n) for tokens',
    keyPoints: [
      'strtok modifies original string',
      'Custom tokenizer can be non-destructive',
      'strtok_r is thread-safe version',
      'Useful for parsing CSV, config files',
    ],
    iconName: 'call_split',
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

  // Pointers - Program 2: Function Pointers
  DSProgram(
    id: 'function_pointers',
    title: 'Function Pointers',
    topic: 'Pointers',
    description: 'Pointers that point to functions',
    explanation: '''
Function pointers store addresses of functions.

**Syntax:**
return_type (*pointer_name)(parameter_types);

**Example:**
int (*operation)(int, int);
operation = &add;  // or just add
result = operation(5, 3);

**Uses:**
• Callback functions
• Strategy pattern
• Event handlers
• Generic sorting (qsort)
• Plugin systems
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

// Functions to point to
int add(int a, int b) { return a + b; }
int subtract(int a, int b) { return a - b; }
int multiply(int a, int b) { return a * b; }
int divide(int a, int b) { return b != 0 ? a / b : 0; }

// Function taking function pointer as argument
int calculate(int a, int b, int (*operation)(int, int)) {
    return operation(a, b);
}

// Comparison function for qsort
int compareAsc(const void* a, const void* b) {
    return (*(int*)a - *(int*)b);
}

int compareDesc(const void* a, const void* b) {
    return (*(int*)b - *(int*)a);
}

// Array of function pointers (calculator)
typedef int (*Operation)(int, int);

int main() {
    printf("=== BASIC FUNCTION POINTER ===\\n");
    int (*op)(int, int);  // Declare function pointer
    
    op = add;
    printf("add(10, 5) = %d\\n", op(10, 5));
    
    op = subtract;
    printf("subtract(10, 5) = %d\\n", op(10, 5));
    
    printf("\\n=== CALLBACK PATTERN ===\\n");
    printf("calculate(10, 5, add) = %d\\n", calculate(10, 5, add));
    printf("calculate(10, 5, multiply) = %d\\n", calculate(10, 5, multiply));
    
    printf("\\n=== ARRAY OF FUNCTION POINTERS ===\\n");
    Operation operations[] = {add, subtract, multiply, divide};
    const char* names[] = {"Add", "Subtract", "Multiply", "Divide"};
    
    int a = 20, b = 4;
    for (int i = 0; i < 4; i++) {
        printf("%s(%d, %d) = %d\\n", names[i], a, b, operations[i](a, b));
    }
    
    printf("\\n=== QSORT WITH COMPARATOR ===\\n");
    int arr[] = {64, 25, 12, 22, 11};
    int n = 5;
    
    qsort(arr, n, sizeof(int), compareAsc);
    printf("Ascending: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    
    qsort(arr, n, sizeof(int), compareDesc);
    printf("\\nDescending: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\\n");
    
    return 0;
}''',
    timeComplexity: 'O(1) for pointer call',
    spaceComplexity: 'O(1)',
    keyPoints: [
      'Store function address in pointer',
      'Enable callbacks and polymorphism',
      'Array of function pointers for dispatch',
      'Used in qsort, signal handlers',
    ],
    iconName: 'functions',
    colorValue: 0xFF8E44AD,
  ),

  // Pointers - Program 3: Pointer to Array
  DSProgram(
    id: 'pointer_to_array',
    title: 'Pointer to Array',
    topic: 'Pointers',
    description: 'Understanding array-pointer relationship',
    explanation: '''
Arrays and pointers are closely related but not identical.

**Key Differences:**
• Array name is constant pointer to first element
• sizeof(array) gives total size
• sizeof(pointer) gives pointer size (4 or 8)

**Pointer to Array:**
int (*ptr)[5];  // Pointer to array of 5 ints
int *ptr[5];    // Array of 5 int pointers (different!)

**Passing Arrays:**
void func(int arr[]) ≡ void func(int *arr)
Array decays to pointer when passed.
''',
    code: '''#include <stdio.h>

void printArray(int* arr, int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
}

// Pointer to 2D array row
void print2D(int (*arr)[4], int rows) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < 4; j++) {
            printf("%d ", arr[i][j]);
        }
        printf("\\n");
    }
}

int main() {
    printf("=== ARRAY VS POINTER ===\\n");
    int arr[] = {10, 20, 30, 40, 50};
    int* ptr = arr;
    
    printf("Array: %p, Pointer: %p\\n", (void*)arr, (void*)ptr);
    printf("sizeof(arr): %zu, sizeof(ptr): %zu\\n\\n", sizeof(arr), sizeof(ptr));
    
    printf("=== POINTER ARITHMETIC ===\\n");
    printf("arr[2] = %d\\n", arr[2]);
    printf("*(arr + 2) = %d\\n", *(arr + 2));
    printf("*(ptr + 2) = %d\\n", *(ptr + 2));
    printf("ptr[2] = %d\\n\\n", ptr[2]);
    
    printf("=== POINTER TO ARRAY ===\\n");
    int (*arrPtr)[5] = &arr;  // Pointer to whole array
    
    printf("arrPtr: %p\\n", (void*)arrPtr);
    printf("*arrPtr (first element addr): %p\\n", (void*)*arrPtr);
    printf("(*arrPtr)[2] = %d\\n\\n", (*arrPtr)[2]);
    
    // Increment moves by entire array size
    printf("arrPtr + 1: %p (jumps %zu bytes)\\n\\n", 
           (void*)(arrPtr + 1), sizeof(arr));
    
    printf("=== 2D ARRAY WITH POINTER ===\\n");
    int matrix[3][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12}
    };
    
    print2D(matrix, 3);
    
    printf("\\n=== ARRAY OF POINTERS VS POINTER TO ARRAY ===\\n");
    int a = 1, b = 2, c = 3;
    int* ptrArr[3] = {&a, &b, &c};  // Array of 3 pointers
    
    printf("Array of pointers: ");
    for (int i = 0; i < 3; i++) {
        printf("%d ", *ptrArr[i]);
    }
    printf("\\n");
    
    return 0;
}''',
    timeComplexity: 'O(1) for access',
    spaceComplexity: 'O(1) for pointer',
    keyPoints: [
      'Array name is constant pointer',
      'sizeof differs between array and pointer',
      'int (*p)[n] vs int *p[n] are different',
      'Arrays decay to pointers when passed',
    ],
    iconName: 'view_array',
    colorValue: 0xFF8E44AD,
  ),

  // Pointers - Program 4: Double Pointers
  DSProgram(
    id: 'double_pointers',
    title: 'Double Pointers (Pointer to Pointer)',
    topic: 'Pointers',
    description: 'Pointers pointing to other pointers',
    explanation: '''
Double pointer stores address of another pointer.

**Declaration:**
int x = 10;
int *p = &x;     // p points to x
int **pp = &p;   // pp points to p

**Accessing:**
**pp = x value (10)
*pp = p value (address of x)
pp = address of p

**Common Uses:**
• 2D dynamic arrays
• Modifying pointer in function
• Array of strings
• Linked list head modification
''',
    code: '''#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Modify pointer value (need double pointer)
void allocateArray(int** ptr, int n) {
    *ptr = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        (*ptr)[i] = i * 10;
    }
}

// Create 2D dynamic array
int** create2DArray(int rows, int cols) {
    int** arr = (int**)malloc(rows * sizeof(int*));
    for (int i = 0; i < rows; i++) {
        arr[i] = (int*)malloc(cols * sizeof(int));
        for (int j = 0; j < cols; j++) {
            arr[i][j] = i * cols + j;
        }
    }
    return arr;
}

void free2DArray(int** arr, int rows) {
    for (int i = 0; i < rows; i++) {
        free(arr[i]);
    }
    free(arr);
}

int main() {
    printf("=== BASIC DOUBLE POINTER ===\\n");
    int x = 100;
    int* p = &x;
    int** pp = &p;
    
    printf("x = %d\\n", x);
    printf("*p = %d\\n", *p);
    printf("**pp = %d\\n", **pp);
    printf("\\nAddresses:\\n");
    printf("&x = %p\\n", (void*)&x);
    printf("p = %p, &p = %p\\n", (void*)p, (void*)&p);
    printf("*pp = %p, pp = %p\\n\\n", (void*)*pp, (void*)pp);
    
    // Modify through double pointer
    **pp = 200;
    printf("After **pp = 200: x = %d\\n\\n", x);
    
    printf("=== ALLOCATE VIA FUNCTION ===\\n");
    int* arr = NULL;
    allocateArray(&arr, 5);
    
    printf("Allocated array: ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", arr[i]);
    }
    printf("\\n");
    free(arr);
    
    printf("\\n=== 2D DYNAMIC ARRAY ===\\n");
    int** matrix = create2DArray(3, 4);
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            printf("%2d ", matrix[i][j]);
        }
        printf("\\n");
    }
    free2DArray(matrix, 3);
    
    printf("\\n=== ARRAY OF STRINGS ===\\n");
    char* names[] = {"Alice", "Bob", "Charlie"};
    char** namePtr = names;
    
    for (int i = 0; i < 3; i++) {
        printf("names[%d] = %s\\n", i, namePtr[i]);
    }
    
    return 0;
}''',
    timeComplexity: 'O(1) for access',
    spaceComplexity: 'O(1) for pointer',
    keyPoints: [
      'Double pointer points to a pointer',
      'Needed to modify pointer in function',
      'Used for 2D dynamic arrays',
      'char** is common for string arrays',
    ],
    iconName: 'compress',
    colorValue: 0xFF8E44AD,
  ),

  // Pointers - Program 5: Linked List with Pointers
  DSProgram(
    id: 'pointer_linked_list',
    title: 'Linked List with Pointers',
    topic: 'Pointers',
    description: 'Build data structures using pointers',
    explanation: '''
Pointers enable linked data structures.

**Node Structure:**
struct Node {
    int data;
    struct Node* next;  // Self-referential
};

**Key Concepts:**
• Self-referential structures
• Dynamic memory allocation
• Pointer chaining
• NULL termination

**Why Pointers:**
• Dynamic size
• Efficient insert/delete
• No contiguous memory needed
''',
    code: '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* createNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->next = NULL;
    return node;
}

// Insert at beginning (modifies head pointer)
void insertFront(struct Node** head, int data) {
    struct Node* newNode = createNode(data);
    newNode->next = *head;
    *head = newNode;
}

// Insert at end
void insertEnd(struct Node** head, int data) {
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
}

// Delete by value
void deleteNode(struct Node** head, int key) {
    struct Node* temp = *head;
    struct Node* prev = NULL;
    
    // If head holds the key
    if (temp != NULL && temp->data == key) {
        *head = temp->next;
        free(temp);
        return;
    }
    
    // Search for key
    while (temp != NULL && temp->data != key) {
        prev = temp;
        temp = temp->next;
    }
    
    if (temp == NULL) return;  // Not found
    
    prev->next = temp->next;
    free(temp);
}

// Reverse the list
void reverse(struct Node** head) {
    struct Node* prev = NULL;
    struct Node* current = *head;
    struct Node* next = NULL;
    
    while (current != NULL) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    *head = prev;
}

void printList(struct Node* head) {
    while (head != NULL) {
        printf("%d -> ", head->data);
        head = head->next;
    }
    printf("NULL\\n");
}

void freeList(struct Node* head) {
    struct Node* temp;
    while (head != NULL) {
        temp = head;
        head = head->next;
        free(temp);
    }
}

int main() {
    struct Node* head = NULL;
    
    printf("=== BUILDING LINKED LIST ===\\n");
    insertEnd(&head, 10);
    insertEnd(&head, 20);
    insertEnd(&head, 30);
    insertFront(&head, 5);
    
    printf("List: ");
    printList(head);
    
    printf("\\n=== DELETE NODE ===\\n");
    printf("Delete 20: ");
    deleteNode(&head, 20);
    printList(head);
    
    printf("\\n=== REVERSE LIST ===\\n");
    printf("Before: ");
    printList(head);
    reverse(&head);
    printf("After:  ");
    printList(head);
    
    printf("\\n=== POINTER VISUALIZATION ===\\n");
    struct Node* temp = head;
    while (temp != NULL) {
        printf("Node at %p: data=%d, next=%p\\n", 
               (void*)temp, temp->data, (void*)temp->next);
        temp = temp->next;
    }
    
    freeList(head);
    return 0;
}''',
    timeComplexity: 'Insert/Delete: O(1) at front, O(n) at end',
    spaceComplexity: 'O(n)',
    keyPoints: [
      'Self-referential structure for nodes',
      'Double pointer to modify head',
      'Always free dynamically allocated nodes',
      'Foundation for complex data structures',
    ],
    iconName: 'link',
    colorValue: 0xFF8E44AD,
  ),
];
