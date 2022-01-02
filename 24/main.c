#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

const unsigned MAX_LENGTH = 256;

void answer(int *processed, bool high)
{
   int vals[14];
   for (int i = 0; i < 14; i++)
   {
      int dep = processed[i] >> 16;
      if (dep)
      {
         vals[i] = vals[dep & 0xFF] + (dep >> 8);
      }
      else
      {
         vals[i] = (processed[i] >> (8 * high)) & 0xFF;
      }
   }

   for (int i = 0; i < 14; i++)
   {
      printf("%d", vals[i]);
   }
   printf("\n");
}

int main()
{
   FILE *file = fopen("input.txt", "r");

   char buffer[MAX_LENGTH];

   int line_idx = 0;
   int digit_idx = -1;
   bool pop, push;

   int processed[14] = {257};
   int stack[14];
   int top = -1;
   int z_offset;

   while (fgets(buffer, MAX_LENGTH, file))
   {
      if (strncmp(buffer, "inp", 3) == 0)
      {
         if (pop)
         {
            top--;
         }

         if (push)
         {
            top++;
            stack[top] = z_offset + (digit_idx << 8);
         }

         digit_idx += 1;

         pop = false;
         push = true;
      }
      else if (strcmp(buffer, "div z 26\n") == 0)
      {
         pop = true;
      }
      else if (line_idx - (18 * digit_idx) == 15)
      {
         char add_str[3];
         strncpy(add_str, &buffer[6], strlen(buffer) - 6);
         z_offset = atoi(add_str);
      }
      else if (top > -1 && strncmp(buffer, "add x", 5) == 0 && buffer[6] != 'z')
      {
         char add_str[3];
         strncpy(add_str, &buffer[6], strlen(buffer) - 6);
         int add = atoi(add_str);
         int dep_add = stack[top] & 0xFF;
         int diff = dep_add + add;

         if (diff < 9)
         {
            int dep_idx = (stack[top] >> 8) & 0xFF;
            if (diff >= 0)
            {
               processed[dep_idx] = 1 + ((9 - diff) << 8);
            }
            else
            {
               processed[dep_idx] = (1 - diff) + (9 << 8);
            }
            processed[digit_idx] |= (dep_idx << 16) | (diff << 24);

            push = false;
         }
      }

      line_idx += 1;
   }

   fclose(file);

   // Part one
   answer(processed, true);
   // Part two
   answer(processed, false);
}