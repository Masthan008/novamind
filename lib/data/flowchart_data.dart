class FlowchartTopic {
  final String id;
  final String title;
  final String problem;
  final List<String> algorithm;
  final String code;
  final String realWorldUse;
  final String imagePath;
  final String difficulty; // 'Easy', 'Medium', 'Hard'

  FlowchartTopic({
    required this.id,
    required this.title,
    required this.problem,
    required this.algorithm,
    required this.code,
    required this.realWorldUse,
    required this.imagePath,
    required this.difficulty,
  });
}

class FlowchartData {
  static final List<FlowchartTopic> topics = [
    FlowchartTopic(
      id: '1',
      title: 'Check Even or Odd Number',
      problem: 'Determine if a user-entered number is even or odd.',
      algorithm: [
        '1. Start',
        '2. Input number',
        '3. Check if number % 2 == 0',
        '4. If yes → Print "Even"',
        '5. If no → Print "Odd"',
        '6. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int num;
    printf("Enter a number: ");
    scanf("%d", &num);
    
    if (num % 2 == 0)
        printf("%d is Even\\n", num);
    else
        printf("%d is Odd\\n", num);
    
    return 0;
}''',
      realWorldUse: 'Banking systems to separate transaction IDs, inventory management for even/odd stock counts.',
      imagePath: 'assets/images/flowcharts/flowchart_even_odd.webp',
      difficulty: 'Easy',
    ),
    FlowchartTopic(
      id: '2',
      title: 'Find Largest of Three Numbers',
      problem: 'Compare three numbers and find the largest.',
      algorithm: [
        '1. Start',
        '2. Input three numbers (a, b, c)',
        '3. Check if a > b',
        '4. If yes, check if a > c → a is largest',
        '5. If no, check if b > c → b is largest',
        '6. Else → c is largest',
        '7. Print largest number',
        '8. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int a, b, c, largest;
    printf("Enter three numbers: ");
    scanf("%d %d %d", &a, &b, &c);
    
    if (a > b && a > c)
        largest = a;
    else if (b > c)
        largest = b;
    else
        largest = c;
    
    printf("Largest: %d\\n", largest);
    return 0;
}''',
      realWorldUse: 'E-commerce price comparison, sports score ranking, temperature monitoring systems.',
      imagePath: 'assets/images/flowcharts/flowchart_largest_three.webp',
      difficulty: 'Easy',
    ),
    FlowchartTopic(
      id: '3',
      title: 'Calculate Factorial',
      problem: 'Calculate factorial of a number using loop.',
      algorithm: [
        '1. Start',
        '2. Input number n',
        '3. Initialize fact = 1, i = 1',
        '4. Loop while i <= n',
        '5. fact = fact * i',
        '6. i = i + 1',
        '7. Print fact',
        '8. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, i;
    long long fact = 1;
    
    printf("Enter a number: ");
    scanf("%d", &n);
    
    for (i = 1; i <= n; i++) {
        fact *= i;
    }
    
    printf("Factorial of %d = %lld\\n", n, fact);
    return 0;
}''',
      realWorldUse: 'Probability calculations, permutation/combination in data science, cryptography algorithms.',
      imagePath: 'assets/images/flowcharts/flowchart_factorial.webp',
      difficulty: 'Medium',
    ),
    FlowchartTopic(
      id: '4',
      title: 'Check Prime Number',
      problem: 'Determine if a number is prime.',
      algorithm: [
        '1. Start',
        '2. Input number n',
        '3. If n <= 1 → Not Prime',
        '4. Initialize i = 2',
        '5. Loop while i <= n/2',
        '6. If n % i == 0 → Not Prime, Exit',
        '7. i = i + 1',
        '8. If loop completes → Prime',
        '9. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, i, isPrime = 1;
    
    printf("Enter a number: ");
    scanf("%d", &n);
    
    if (n <= 1) isPrime = 0;
    
    for (i = 2; i <= n/2; i++) {
        if (n % i == 0) {
            isPrime = 0;
            break;
        }
    }
    
    if (isPrime)
        printf("%d is Prime\\n", n);
    else
        printf("%d is Not Prime\\n", n);
    
    return 0;
}''',
      realWorldUse: 'Cryptography (RSA encryption), hash table sizing, random number generation.',
      imagePath: 'assets/images/flowcharts/flowchart_prime_check.webp',
      difficulty: 'Medium',
    ),
    FlowchartTopic(
      id: '5',
      title: 'Reverse a Number',
      problem: 'Reverse the digits of a number.',
      algorithm: [
        '1. Start',
        '2. Input number n',
        '3. Initialize reverse = 0',
        '4. Loop while n != 0',
        '5. digit = n % 10',
        '6. reverse = reverse * 10 + digit',
        '7. n = n / 10',
        '8. Print reverse',
        '9. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, reverse = 0, digit;
    
    printf("Enter a number: ");
    scanf("%d", &n);
    
    while (n != 0) {
        digit = n % 10;
        reverse = reverse * 10 + digit;
        n /= 10;
    }
    
    printf("Reversed: %d\\n", reverse);
    return 0;
}''',
      realWorldUse: 'Palindrome checking, data validation, number pattern recognition in ML.',
      imagePath: 'assets/images/flowcharts/flowchart_reverse_number.webp',
      difficulty: 'Medium',
    ),
    FlowchartTopic(
      id: '6',
      title: 'Fibonacci Series',
      problem: 'Generate Fibonacci sequence up to n terms.',
      algorithm: [
        '1. Start',
        '2. Input n (number of terms)',
        '3. Initialize a = 0, b = 1',
        '4. Print a, b',
        '5. Loop from i = 3 to n',
        '6. c = a + b',
        '7. Print c',
        '8. a = b, b = c',
        '9. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, i, a = 0, b = 1, c;
    
    printf("Enter number of terms: ");
    scanf("%d", &n);
    
    printf("Fibonacci Series: %d %d ", a, b);
    
    for (i = 3; i <= n; i++) {
        c = a + b;
        printf("%d ", c);
        a = b;
        b = c;
    }
    printf("\\n");
    return 0;
}''',
      realWorldUse: 'Stock market analysis, nature patterns (sunflower seeds), algorithm optimization.',
      imagePath: 'assets/images/flowcharts/flowchart_fibonacci.webp',
      difficulty: 'Medium',
    ),
    FlowchartTopic(
      id: '7',
      title: 'Linear Search in Array',
      problem: 'Search for an element in an array.',
      algorithm: [
        '1. Start',
        '2. Input array size n',
        '3. Input array elements',
        '4. Input search key',
        '5. Initialize found = 0, i = 0',
        '6. Loop while i < n',
        '7. If arr[i] == key → found = 1, position = i, break',
        '8. i = i + 1',
        '9. If found → Print position',
        '10. Else → Print "Not Found"',
        '11. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, i, key, found = 0;
    
    printf("Enter array size: ");
    scanf("%d", &n);
    int arr[n];
    
    printf("Enter elements: ");
    for (i = 0; i < n; i++)
        scanf("%d", &arr[i]);
    
    printf("Enter search key: ");
    scanf("%d", &key);
    
    for (i = 0; i < n; i++) {
        if (arr[i] == key) {
            printf("Found at position %d\\n", i);
            found = 1;
            break;
        }
    }
    
    if (!found)
        printf("Not Found\\n");
    
    return 0;
}''',
      realWorldUse: 'Database queries, contact search in phonebook, product search in e-commerce.',
      imagePath: 'assets/images/flowcharts/flowchart_linear_search.webp',
      difficulty: 'Medium',
    ),
    FlowchartTopic(
      id: '8',
      title: 'Bubble Sort Algorithm',
      problem: 'Sort an array in ascending order.',
      algorithm: [
        '1. Start',
        '2. Input array size n',
        '3. Input array elements',
        '4. Outer loop: i = 0 to n-1',
        '5. Inner loop: j = 0 to n-i-1',
        '6. If arr[j] > arr[j+1] → Swap',
        '7. Print sorted array',
        '8. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, i, j, temp;
    
    printf("Enter array size: ");
    scanf("%d", &n);
    int arr[n];
    
    printf("Enter elements: ");
    for (i = 0; i < n; i++)
        scanf("%d", &arr[i]);
    
    // Bubble Sort
    for (i = 0; i < n-1; i++) {
        for (j = 0; j < n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
    
    printf("Sorted Array: ");
    for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\\n");
    
    return 0;
}''',
      realWorldUse: 'Leaderboard ranking, price sorting in shopping apps, student grade sorting.',
      imagePath: 'assets/images/flowcharts/flowchart_bubble_sort.webp',
      difficulty: 'Hard',
    ),
    FlowchartTopic(
      id: '9',
      title: 'Calculate Sum of Digits',
      problem: 'Find sum of all digits in a number.',
      algorithm: [
        '1. Start',
        '2. Input number n',
        '3. Initialize sum = 0',
        '4. Loop while n != 0',
        '5. digit = n % 10',
        '6. sum = sum + digit',
        '7. n = n / 10',
        '8. Print sum',
        '9. End',
      ],
      code: '''#include <stdio.h>
int main() {
    int n, sum = 0, digit;
    
    printf("Enter a number: ");
    scanf("%d", &n);
    
    while (n != 0) {
        digit = n % 10;
        sum += digit;
        n /= 10;
    }
    
    printf("Sum of digits: %d\\n", sum);
    return 0;
}''',
      realWorldUse: 'Credit card validation (Luhn algorithm), checksum calculations, digital root in numerology apps.',
      imagePath: 'assets/images/flowcharts/flowchart_sum_digits.webp',
      difficulty: 'Easy',
    ),
    FlowchartTopic(
      id: '10',
      title: 'Simple Calculator',
      problem: 'Perform basic arithmetic operations.',
      algorithm: [
        '1. Start',
        '2. Input two numbers (a, b)',
        '3. Input operator (+, -, *, /)',
        '4. Check operator using switch/if',
        '5. Case "+": result = a + b',
        '6. Case "-": result = a - b',
        '7. Case "*": result = a * b',
        '8. Case "/": Check b != 0, result = a / b',
        '9. Default: Invalid operator',
        '10. Print result',
        '11. End',
      ],
      code: '''#include <stdio.h>
int main() {
    float a, b, result;
    char op;
    
    printf("Enter two numbers: ");
    scanf("%f %f", &a, &b);
    
    printf("Enter operator (+, -, *, /): ");
    scanf(" %c", &op);
    
    switch(op) {
        case '+': result = a + b; break;
        case '-': result = a - b; break;
        case '*': result = a * b; break;
        case '/': 
            if (b != 0) result = a / b;
            else { printf("Error: Division by zero\\n"); return 1; }
            break;
        default: printf("Invalid operator\\n"); return 1;
    }
    
    printf("Result: %.2f\\n", result);
    return 0;
}''',
      realWorldUse: 'Calculator apps, financial calculations, scientific computing.',
      imagePath: 'assets/images/flowcharts/flowchart_calculator.webp',
      difficulty: 'Medium',
    ),
  ];

  // Get topics by difficulty
  static List<FlowchartTopic> getByDifficulty(String difficulty) {
    return topics.where((topic) => topic.difficulty == difficulty).toList();
  }

  // Get easy topics
  static List<FlowchartTopic> get easyTopics => getByDifficulty('Easy');

  // Get medium topics
  static List<FlowchartTopic> get mediumTopics => getByDifficulty('Medium');

  // Get hard topics
  static List<FlowchartTopic> get hardTopics => getByDifficulty('Hard');
}
